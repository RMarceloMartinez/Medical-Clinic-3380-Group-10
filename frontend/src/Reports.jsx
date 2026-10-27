import { useState } from 'react'
import { api } from './api'

export default function Reports({ role }) {
  const [report, setReport] = useState('revenue')
  const [from, setFrom] = useState('')
  const [to, setTo] = useState('')
  const [rows, setRows] = useState([])
  const [error, setError] = useState('')

    async function runReport() {
    setError('')

    if (from === '' || to === '') {
      setError('Pick both dates.')
      return
    }

    try {
      const data = await api.get(`/reports/${report}?from=${from}&to=${to}`)
      setRows(data)
    } catch (e) {
      setError(e.message)
      setRows([])
    }
  }
  

  return (
    <div className="reports">
        <h2>Clinic Reports</h2>
        <div className="report-picker">
        <button onClick={() => { setReport('revenue'); setRows([]) }}>Revenue</button>
        <button onClick={() => { setReport('activity'); setRows([]) }}>Appointment activity</button>
        </div>
        <div className="filters">
        From <input type="date" value={from} onChange={(e) => setFrom(e.target.value)} />
        To <input type="date" value={to} onChange={(e) => setTo(e.target.value)} />
        <button onClick={runReport}>Run report</button>
        </div>

        {error && <p className="error-message">{error}</p>}

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
                <td>${r.billed.toFixed(2)}</td>
                <td>${r.collected.toFixed(2)}</td>
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