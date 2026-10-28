import { useEffect, useState } from 'react'
import { api } from '../../api/client'
import './Reports.css'

// Admin reports: R1 office revenue, R2 appointment activity, R3 patient health summary.
const REPORTS = [
  ['revenue', 'Office revenue'],
  ['activity', 'Appointment activity'],
  ['health-summary', 'Patient health summary'],
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

    setLoading(true)
    try {
      setRows(await api.get(url))
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

      {hasRun && rows.length === 0 && (
        <p className="report-empty">No matching records found.</p>
      )}

      {report === 'revenue' && rows.length > 0 && <RevenueReport rows={rows} />}
      {report === 'activity' && rows.length > 0 && <ActivityReport rows={rows} />}
      {report === 'health-summary' && rows.length > 0 && <HealthSummary rows={rows} />}
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
