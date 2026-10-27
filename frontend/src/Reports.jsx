import { useState } from 'react'
import { api } from './api'

export default function Reports({ role }) {
  const [report, setReport] = useState('revenue')
  const [from, setFrom] = useState('')
  const [to, setTo] = useState('')
  const [rows, setRows] = useState([])
  const [error, setError] = useState('')
  const [patientId, setPatientId] = useState('')
  const [loading, setLoading] = useState(false)
  const [hasRun, setHasRun] = useState(false)

    async function runReport() {
      setError('')
      setRows([])
      setHasRun(false)

      let url

      if (report === 'health-summary') {
        const id = patientId.trim()

      if (!/^[1-9]\d{6}$/.test(id)) {
        setError('Enter a seven-digit Patient ID.')
        return
      }

      url = `/reports/health-summary?patientId=${id}`
    } else {
      if (!from || !to) {
        setError('Pick both dates.')
        return
      }

      if (from > to) {
        setError('From date must be on or before To date.')
        return
      }

      url = `/reports/${report}?from=${from}&to=${to}`
    }

    setLoading(true)

    try {
      const data = await api.get(url)
      setRows(data)
      setHasRun(true)
    } catch (e) {
      setError(e.message)
    } finally {
      setLoading(false)
    }
  }
  

  return (
    <div className="reports">
        <h2>Clinic Reports</h2>
        <div className="report-picker">
          {[
            ['revenue', 'Revenue'],
            ['activity', 'Appointment activity'],
            ['health-summary', 'Patient Health Summary']
          ].map(([value, label]) => (
            <button
              key={value}
              disabled={loading}
              onClick={() => {
                setReport(value)
                setRows([])
                setError('')
                setHasRun(false)
              }}
            >
              {label}
            </button>
        ))}
      </div>

      <div className="filters">
        {report === 'health-summary' ? (
          <label>
            Patient ID
            <input
              type="text"
              inputMode="numeric"
              maxLength={7}
              value={patientId}
              disabled={loading}
              onChange={(e) => {
                setPatientId(e.target.value)
                setRows([])
                setHasRun(false)
              }}
            />
          </label>
        ) : (
          <>
            <label>
              From
              <input
                type="date"
                value={from}
                disabled={loading}
                onChange={(e) => {
                  setFrom(e.target.value)
                  setRows([])
                  setHasRun(false)
                }}
              />
            </label>
            <label>
              To
              <input
                type="date"
                value={to}
                disabled={loading}
                onChange={(e) => {
                  setTo(e.target.value)
                  setRows([])
                  setHasRun(false)
                }}
              />
            </label>
          </>
        )}

        <button onClick={runReport} disabled={loading}>
          {loading ? 'Loading…' : 'Run report'}
        </button>
      </div>

        {error && <p className="error-message">{error}</p>}

        {hasRun && rows.length === 0 && (
          <p>No matching records found.</p>
        )}

        {report === 'health-summary' && rows.length > 0 && (
          <div>
            <h3>
              {rows[0].patientFirstName} {rows[0].patientLastName}
              {' — ID: '}{rows[0].patientID}
          </h3>

          <table>
            <thead>
              <tr>
                <th>Category</th>
                <th>Item</th>
                <th>Details</th>
                <th>Date</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((row, index) => (
                <tr key={index}>
                  <td>{row.category}</td>
                  <td>{row.itemName}</td>
                  <td>{row.detail || '—'}</td>
                  <td>{row.itemDate ? row.itemDate.slice(0, 10) : '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

              {report === 'revenue' && rows.length > 0 && (
        <table>
          <thead>
            <tr>
              <th>Office</th>
              <th>Completed visits</th>
              <th>Billed</th>
              <th>Collected</th>
              <th>Refunded</th>
              <th>Outstanding</th>
              <th>Cash</th>
              <th>Credit card</th>
              <th>Debit card</th>
              <th>Insurance</th>
              <th>Check</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((r) => (
              <tr key={r.officeID}>
                <td>{r.officeStreetAddress}</td>
                <td>{r.completedVisits}</td>
                <td>${Number(r.billed ?? 0).toFixed(2)}</td>
                <td>${Number(r.collected ?? 0).toFixed(2)}</td>
                <td>${r.refunded.toFixed(2)}</td>
                <td>${r.outstanding.toFixed(2)}</td>
                <td>${r.cashCollected.toFixed(2)}</td>
                <td>${r.creditCardCollected.toFixed(2)}</td>
                <td>${r.debitCardCollected.toFixed(2)}</td>
                <td>${r.insuranceCollected.toFixed(2)}</td>
                <td>${r.checkCollected.toFixed(2)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

            {report === 'activity' && rows.length > 0 && (
        <table>
          <thead>
            <tr>
              <th>Doctor</th>
              <th>Office</th>
              <th>Total</th>
              <th>Scheduled</th>
              <th>Completed</th>
              <th>Cancelled</th>
              <th>By patient</th>
              <th>By doctor</th>
              <th>By staff</th>
              <th>Cancellation rate</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((r) => (
              <tr key={`${r.doctorID}-${r.officeID}`}>
                <td>{r.doctorFirstName} {r.doctorLastName}</td>
                <td>{r.officeStreetAddress}</td>
                <td>{r.totalAppointments}</td>
                <td>{r.scheduled}</td>
                <td>{r.completed}</td>
                <td>{r.cancelled}</td>
                <td>{r.cancelledByPatient}</td>
                <td>{r.cancelledByDoctor}</td>
                <td>{r.cancelledByStaff}</td>
                <td>{r.cancellationRate.toFixed(2)}%</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    
    </div>
  )
  
}