-- migrate-ssn.sql: makes Member.SSN optional (patients) and keeps it unique when given.
-- Safe to run more than once. Run this on Azure, never reset.sql.
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;   -- required to create a filtered index
GO

-- 1. Drop the old UNIQUE constraint (it allows only one NULL)
IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'UQ_Member_SSN')
    ALTER TABLE dbo.Member DROP CONSTRAINT UQ_Member_SSN;
GO

-- 2. Make the column nullable (SQL Server won't change a column a CHECK uses, so drop it first)
IF EXISTS (SELECT 1 FROM sys.columns
           WHERE object_id = OBJECT_ID('dbo.Member') AND name = 'SSN' AND is_nullable = 0)
BEGIN
    IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Member_SSN')
        ALTER TABLE dbo.Member DROP CONSTRAINT CK_Member_SSN;

    ALTER TABLE dbo.Member ALTER COLUMN SSN VARCHAR(11) NULL;
END;
GO

-- 3. Put the format check back (a NULL passes a CHECK)
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Member_SSN')
    ALTER TABLE dbo.Member ADD CONSTRAINT CK_Member_SSN
        CHECK (SSN LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]');
GO

-- 4. Unique only among rows that have an SSN
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'UX_Member_SSN' AND object_id = OBJECT_ID('dbo.Member'))
    CREATE UNIQUE INDEX UX_Member_SSN ON dbo.Member(SSN) WHERE SSN IS NOT NULL;
GO
