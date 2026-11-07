IF NOT EXISTS (SELECT 1 FROM sys.columns
                WHERE object_id = oBJECT_ID('dbo.Appointment') AND name = 'CancellationFee')
        ALTER TABLE dbo.Appointment ADD CancellationFee NUMERIC(10,2) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Appointment_CancellationFee')
    ALTER TABLE dbo.Appointment ADD CONSTRAINT CK_Appointment_CancellationFee
        CHECK(CancellationFee IS NULL OR CancellationFee >= 0);
GO