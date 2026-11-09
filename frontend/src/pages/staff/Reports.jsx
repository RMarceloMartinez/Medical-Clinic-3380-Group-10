import { useEffect, useState } from 'react'
import { api } from '../../api/client'
import DataTable from '../../components/DataTable'
import './Reports.css'

// Admin reports: R1 office revenue, R2 appointment activity, R3 patient health summary.
const REPORTS = [
    ['revenue', 'Office revenue'],
    ['activity', 'Appointment activity'],
    ['health-summary', 'Patient health summary'],
    ['health-trends', 'Health trends'],
]

const money = (n) =>
    Number(n ?? 0).toLocaleString('en-US', { style: 'currency', currency: 'USD' })

// Adds up one field over all rows
const sum = (rows, field) => rows.reduce((total, r) => total + Number(r[field] ?? 0), 0)

export default function Reports() {
    const [report, setReport] = useState('revenue')
    const [from, setFrom] = useState('')
    const [to, setTo] = useState('')
    const [patientId, setPatientId] = useState('')
    const [patients, setPatients] = useState([])
    const [rows, setRows] = useState([])
    const [trends, setTrends] = useState(null)
    const [visits, setVisits] = useState([])
    const [hasRun, setHasRun] = useState(false)
    const [loading, setLoading] = useState(false)
    const [error, setError] = useState('')

    useEffect(() => {
        api.get('/lookups/patients')
            .then(setPatients)
            .catch((e) => setError(`Could not load patients: ${e.message}`))
    }, [])

    // Any change to the report or its inputs clears the old result
    function clearResult() {
        setRows([])
        setTrends(null)
        setVisits([])
        setHasRun(false)
        setError('')
    }

    function pickReport(value) {
        setReport(value)
        clearResult()
    }

    async function runReport() {
        clearResult()

        let url
        if (report === 'health-summary') {
            if (!patientId) {
                setError('Please pick a patient.')
                return
            }
            url = `/reports/health-summary?patientId=${patientId}`
        } else {
            if (!from || !to) {
                setError('Please pick both dates.')
                return
            }
            if (from > to) {
                setError('The From date must be on or before the To date.')
                return
            }
            url = `/reports/${report}?from=${from}&to=${to}`
        }

        // R3: the visits behind the report, with the same filter
        const visitsUrl = report === 'health-summary'
            ? `/reports/visits?patientId=${patientId}`
            : `/reports/visits?from=${from}&to=${to}`

        setLoading(true)
        try {
            const [data, visitRows] = await Promise.all([api.get(url), api.get(visitsUrl)])
            setVisits(visitRows)

            if (report === 'health-trends') {
                setTrends(data)
            } else {
                setRows(data)
            }

            setHasRun(true)
        } catch (e) {
            setError(`Could not run the report: ${e.message}`)
        } finally {
            setLoading(false)
        }
    }

    return (
        <div className="reports-page">
            <h2>Clinic Reports</h2>

            <div className="page-actions report-tabs">
                {REPORTS.map(([value, label]) => (
                    <button
                        key={value}
                        type="button"
                        className={report === value ? 'active' : ''}
                        aria-pressed={report === value}
                        disabled={loading}
                        onClick={() => pickReport(value)}
                    >
                        {label}
                    </button>
                ))}
            </div>

            <div className="filter-bar">
                {report === 'health-summary' ? (
                    <div className="filter-field">
                        <label htmlFor="report-patient">Patient</label>
                        <select
                            id="report-patient"
                            value={patientId}
                            disabled={loading}
                            onChange={(e) => { setPatientId(e.target.value); clearResult() }}
                        >
                            <option value="">Select a patient</option>
                            {patients.map((p) => (
                                <option key={p.id} value={p.id}>{p.name}</option>
                            ))}
                        </select>
                    </div>
                ) : (
                    <>
                        <div className="filter-field">
                            <label htmlFor="report-from">From</label>
                            <input id="report-from" type="date" value={from} disabled={loading}
                                onChange={(e) => { setFrom(e.target.value); clearResult() }} />
                        </div>
                        <div className="filter-field">
                            <label htmlFor="report-to">To</label>
                            <input id="report-to" type="date" value={to} disabled={loading}
                                onChange={(e) => { setTo(e.target.value); clearResult() }} />
                        </div>
                    </>
                )}
                <div className="filter-buttons">
                    <button type="button" className="primary-button" onClick={runReport} disabled={loading}>
                        {loading ? 'Loading…' : 'Run report'}
                    </button>
                </div>
            </div>

            {error && <p className="error-message">{error}</p>}

            {!hasRun && !error && (
                <p className="report-hint">
                    {report === 'health-summary'
                        ? 'Pick a patient, then select Run report.'
                        : 'Pick a date range, then select Run report.'}
                </p>
            )}

            {hasRun && report !== 'health-trends' && rows.length === 0 && (
                <p className="report-empty">No matching records found.</p>
            )}

            {report === 'revenue' && rows.length > 0 && <RevenueReport rows={rows} />}
            {report === 'activity' && rows.length > 0 && <ActivityReport rows={rows} />}
            {report === 'health-summary' && rows.length > 0 && <HealthSummary rows={rows} />}
            {report === 'health-trends' && hasRun && trends && <HealthTrendsReport data={trends} />}

            {hasRun && (rows.length > 0 || trends) && (
                <VisitDetails report={report} visits={visits} from={from} to={to} />
            )}
        </div>
    )
}

function StatCards({ items }) {
    return (
        <div className="report-stats">
            {items.map(([label, value]) => (
                <div className="report-stat" key={label}>
                    <span className="report-stat-label">{label}</span>
                    <span className="report-stat-value">{value}</span>
                </div>
            ))}
        </div>
    )
}

function RevenueReport({ rows }) {
    const methods = [
        ['cashCollected', 'Cash'],
        ['creditCardCollected', 'Credit card'],
        ['debitCardCollected', 'Debit card'],
        ['insuranceCollected', 'Insurance'],
        ['checkCollected', 'Check'],
    ]

    return (
        <>
            <StatCards items={[
                ['Completed visits', sum(rows, 'completedVisits')],
                ['Billed', money(sum(rows, 'billed'))],
                ['Collected', money(sum(rows, 'collected'))],
                ['Outstanding', money(sum(rows, 'outstanding'))],
            ]} />

            <h3 className="report-section-title">By office</h3>
            <div className="report-table-card">
                <table className="data-table report-table">
                    <thead>
                        <tr>
                            <th>Office</th>
                            <th className="num">Visits</th>
                            <th className="num">Billed</th>
                            <th className="num">Collected</th>
                            <th className="num">Refunded</th>
                            <th className="num">Outstanding</th>
                        </tr>
                    </thead>
                    <tbody>
                        {rows.map((r) => (
                            <tr key={r.officeID}>
                                <td>{r.officeStreetAddress}</td>
                                <td className="num">{r.completedVisits}</td>
                                <td className="num">{money(r.billed)}</td>
                                <td className="num">{money(r.collected)}</td>
                                <td className="num">{money(r.refunded)}</td>
                                <td className={`num ${Number(r.outstanding) > 0 ? 'owed' : ''}`}>{money(r.outstanding)}</td>
                            </tr>
                        ))}
                    </tbody>
                    <tfoot>
                        <tr>
                            <td>Total</td>
                            <td className="num">{sum(rows, 'completedVisits')}</td>
                            <td className="num">{money(sum(rows, 'billed'))}</td>
                            <td className="num">{money(sum(rows, 'collected'))}</td>
                            <td className="num">{money(sum(rows, 'refunded'))}</td>
                            <td className="num">{money(sum(rows, 'outstanding'))}</td>
                        </tr>
                    </tfoot>
                </table>
            </div>

            <h3 className="report-section-title">Collected by payment method</h3>
            <div className="report-table-card">
                <table className="data-table report-table">
                    <thead>
                        <tr>
                            <th>Office</th>
                            {methods.map(([, label]) => <th key={label} className="num">{label}</th>)}
                        </tr>
                    </thead>
                    <tbody>
                        {rows.map((r) => (
                            <tr key={r.officeID}>
                                <td>{r.officeStreetAddress}</td>
                                {methods.map(([field]) => <td key={field} className="num">{money(r[field])}</td>)}
                            </tr>
                        ))}
                    </tbody>
                    <tfoot>
                        <tr>
                            <td>Total</td>
                            {methods.map(([field]) => <td key={field} className="num">{money(sum(rows, field))}</td>)}
                        </tr>
                    </tfoot>
                </table>
            </div>
        </>
    )
}

function ActivityReport({ rows }) {
    const total = sum(rows, 'totalAppointments')
    const cancelled = sum(rows, 'cancelled')
    const rate = total > 0 ? (cancelled / total) * 100 : 0

    return (
        <>
            <StatCards items={[
                ['Appointments', total],
                ['Completed', sum(rows, 'completed')],
                ['Scheduled', sum(rows, 'scheduled')],
                ['Cancellation rate', `${rate.toFixed(1)}%`],
            ]} />

            <h3 className="report-section-title">By doctor and office</h3>
            <div className="report-table-card">
                <table className="data-table report-table">
                    <thead>
                        <tr>
                            <th>Doctor</th>
                            <th className="num">Total</th>
                            <th className="num">Scheduled</th>
                            <th className="num">Completed</th>
                            <th className="num">Cancelled</th>
                            <th>Cancelled by</th>
                            <th className="num">Cancel rate</th>
                        </tr>
                    </thead>
                    <tbody>
                        {rows.map((r) => (
                            <tr key={`${r.doctorID}-${r.officeID}`}>
                                <td>
                                    <div className="cell-main">Dr. {r.doctorFirstName} {r.doctorLastName}</div>
                                    <div className="cell-sub">{r.officeStreetAddress}</div>
                                </td>
                                <td className="num">{r.totalAppointments}</td>
                                <td className="num">{r.scheduled}</td>
                                <td className="num">{r.completed}</td>
                                <td className="num">{r.cancelled}</td>
                                <td className="cancel-split">
                                    Patient {r.cancelledByPatient} · Doctor {r.cancelledByDoctor} · Staff {r.cancelledByStaff}
                                </td>
                                <td className="num">{Number(r.cancellationRate ?? 0).toFixed(1)}%</td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </>
    )
}

function HealthSummary({ rows }) {
    const first = rows[0]
    // Group rows by category (Condition, Allergy, Diagnosis, ...) keeping the API's order
    const groups = rows.reduce((acc, row) => {
        (acc[row.category] ??= []).push(row)
        return acc
    }, {})

    return (
        <>
            <div className="report-patient">
                <span className="report-stat-label">Patient</span>
                <span className="report-patient-name">{first.patientFirstName} {first.patientLastName}</span>
                <span className="report-patient-id">ID {first.patientID}</span>
            </div>

            {Object.entries(groups).map(([category, items]) => (
                <div key={category}>
                    <h3 className="report-section-title">{category} <span className="report-count">({items.length})</span></h3>
                    <div className="report-table-card">
                        <table className="data-table report-table">
                            <thead>
                                <tr>
                                    <th>Item</th>
                                    <th>Details</th>
                                    <th>Date</th>
                                </tr>
                            </thead>
                            <tbody>
                                {items.map((row, index) => (
                                    <tr key={index}>
                                        <td className="cell-main">{row.itemName}</td>
                                        <td className="wrap">{row.detail || '—'}</td>
                                        <td>{row.itemDate ? row.itemDate.slice(0, 10) : '—'}</td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </div>
            ))}
        </>
    )
}

    function HealthTrendsReport({ data }) {
        const summary = data.conditionSummary ?? []
        const common = data.commonConditions ?? []
        const monthly = data.monthlyDiagnoses ?? []

        return (
            <>
                <p className="report-hint">
                    Condition counts reflect all recorded history.
                    The date filter applies to monthly diagnoses.
                </p>

                <StatCards items={[
                    ['Recorded conditions', sum(summary, 'totalConditions')],
                    ['Chronic conditions', sum(
                        summary.filter(r => r.conditionType?.toLowerCase() === 'chronic'),
                        'totalConditions'
                    )],
                    ['Acute conditions', sum(
                        summary.filter(r => r.conditionType?.toLowerCase() === 'acute'),
                        'totalConditions'
                    )],
                    ['Diagnoses in selected months', sum(monthly, 'totalDiagnoses')],
                ]} />

                <h3 className="report-section-title">Conditions by type</h3>
                <div className="report-table-card">
                    <table className="data-table report-table">
                        <thead>
                            <tr>
                                <th>Type</th>
                                <th className="num">Conditions</th>
                                <th className="num">Patients affected</th>
                                <th className="num">Hereditary</th>
                            </tr>
                        </thead>
                        <tbody>
                            {summary.map((r, i) => (
                                <tr key={i}>
                                    <td>{r.conditionType}</td>
                                    <td className="num">{r.totalConditions}</td>
                                    <td className="num">{r.patientsAffected}</td>
                                    <td className="num">{r.hereditaryConditions}</td>
                                </tr>
                            ))}
                            {summary.length === 0 && (
                                <tr><td colSpan={4}>No recorded conditions.</td></tr>
                            )}
                        </tbody>
                    </table>
                </div>

                <h3 className="report-section-title">10 most common conditions</h3>
                <div className="report-table-card">
                    <table className="data-table report-table">
                        <thead>
                            <tr>
                                <th>Condition</th>
                                <th>Type</th>
                                <th className="num">Cases</th>
                                <th className="num">Patients</th>
                                <th className="num">Severe</th>
                                <th className="num">Hereditary</th>
                            </tr>
                        </thead>
                        <tbody>
                            {common.map((r, i) => (
                                <tr key={i}>
                                    <td>{r.conditionName}</td>
                                    <td>{r.conditionType}</td>
                                    <td className="num">{r.totalCases}</td>
                                    <td className="num">{r.patientsAffected}</td>
                                    <td className="num">{r.severeCases}</td>
                                    <td className="num">{r.hereditaryCases}</td>
                                </tr>
                            ))}
                            {common.length === 0 && (
                                <tr><td colSpan={6}>No recorded conditions.</td></tr>
                            )}
                        </tbody>
                    </table>
                </div>

                <h3 className="report-section-title">Monthly diagnosis trends</h3>
                <div className="report-table-card">
                    <table className="data-table report-table">
                        <thead>
                            <tr>
                                <th>Month</th>
                                <th>Diagnosis type</th>
                                <th className="num">Diagnoses</th>
                                <th className="num">Patients diagnosed</th>
                            </tr>
                        </thead>
                        <tbody>
                            {monthly.map((r, i) => (
                                <tr key={i}>
                                    <td>{String(r.monthStart ?? '').slice(0, 7)}</td>
                                    <td>{r.diagnosisType}</td>
                                    <td className="num">{r.totalDiagnoses}</td>
                                    <td className="num">{r.patientsDiagnosed}</td>
                                </tr>
                            ))}
                            {monthly.length === 0 && (
                                <tr><td colSpan={4}>No diagnoses in the selected months.</td></tr>
                            )}
                        </tbody>
                    </table>
                </div>
            </>
        )
    }

// ----- R3: Visits in this report -----

const shortDate = (value) =>
    new Date(`${value}T00:00:00`).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })

const visitColumns = [
    {
        key: 'visitDateTime', label: 'Date and time',
        format: (v) => new Date(v.visitDateTime).toLocaleString('en-US',
            { month: 'short', day: 'numeric', year: 'numeric', hour: 'numeric', minute: '2-digit' }),
        sortValue: (v) => v.visitDateTime,
    },
    { key: 'patientName', label: 'Patient' },
    { key: 'doctorName', label: 'Doctor', format: (v) => `${v.doctorName} (${v.specialty})` },
    { key: 'officeStreetAddress', label: 'Office' },
    {
        key: 'appointStatus', label: 'Status',
        format: (v) => (v.cancelledBy ? `Cancelled by ${v.cancelledBy.toLowerCase()}` : v.appointStatus),
    },
    { key: 'totalCost', label: 'Cost', format: (v) => money(v.totalCost) },
    { key: 'amountPaid', label: 'Paid', format: (v) => money(v.amountPaid) },
    { key: 'cancellationFee', label: 'Late-cancel fee', format: (v) => (v.cancellationFee ? money(v.cancellationFee) : '—') },
    { key: 'diagnoses', label: 'Diagnoses', format: (v) => v.diagnoses ?? '—' },
]

// The same visits the summary above counts, one row each, sortable and filterable
function VisitDetails({ report, visits, from, to }) {
    const shown =
        report === 'revenue' ? visits.filter((v) => v.appointStatus === 'Completed')
        : report === 'health-trends' ? visits.filter((v) => v.appointStatus === 'Completed' && v.diagnoses)
        : visits

    const empty = report === 'health-summary'
        ? 'This patient has no visits yet.'
        : `No visits between ${shortDate(from)} and ${shortDate(to)}.`

    return (
        <>
            <h3 className="report-section-title">
                Visits in this report <span className="report-count">({shown.length})</span>
            </h3>
            <DataTable
                columns={visitColumns}
                rows={shown}
                rowKey={(v) => v.appointmentID}
                initialSort={report === 'revenue' ? 'officeStreetAddress' : null}
                filterLabel="Filter visits"
                emptyMessage={empty}
            />
        </>
    )
}
