import { useEffect, useState } from 'react'
import { api } from '../../api/client'

function formatDateTime(value) {
  return new Date(value).toLocaleString([], { dateStyle: 'medium', timeStyle: 'short' })
}

// The logged-in patient's own appointments. Three screens:
//   'upcoming' (with Cancel), 'past' (history), 'cancel' (confirm one cancellation)
export default function MyAppointments({ onBook }) {
  const [view, setView] = useState('upcoming')
  const [appointments, setAppointments] = useState([])
  const [loaded, setLoaded] = useState(false)
  const [toCancel, setToCancel] = useState(null)
  const [reason, setReason] = useState('')
  const [error, setError] = useState('')
  const [message, setMessage] = useState('')

  async function load() {
    try {
      setAppointments(await api.get('/me/appointments'))
    } catch (e) {
      setError(e.message)
    } finally {
      setLoaded(true)
    }
  }

  useEffect(() => {
    api.get('/me/appointments')
      .then(setAppointments)
      .catch((e) => setError(e.message))
      .finally(() => setLoaded(true))
  }, [])

  const now = new Date()
  const upcoming = appointments
    .filter((a) => a.appointStatus === 'Scheduled' && new Date(a.appointmentDateTime) >= now)
    .sort((x, y) => new Date(x.appointmentDateTime) - new Date(y.appointmentDateTime))
  const past = appointments
    .filter((a) => !upcoming.includes(a))
    .sort((x, y) => new Date(y.appointmentDateTime) - new Date(x.appointmentDateTime))

  function startCancel(a) {
    setError('')
    setMessage('')
    setReason('')
    setToCancel(a)
    setView('cancel')
  }

  async function confirmCancel() {
    if (reason.trim() === '') {
      setError('Please tell us why you are cancelling.')
      return
    }
    try {
      await api.post(`/me/appointments/${toCancel.appointmentID}/cancel`, { cancelReason: reason.trim() })
      setMessage(`Your appointment on ${formatDateTime(toCancel.appointmentDateTime)} was cancelled.`)
      setToCancel(null)
      setView('upcoming')
      await load()
    } catch (e) {
      setError(e.message)
    }
  }

  function backToList() {
    setError('')
    setToCancel(null)
    setView('upcoming')
  }

  if (view === 'cancel' && toCancel) {
    return (
      <div className="panel">
        <h2>Cancel appointment</h2>
        <p>
          <strong>{formatDateTime(toCancel.appointmentDateTime)}</strong> with {toCancel.doctorName}<br />
          {toCancel.officeAddress}
        </p>
        <label htmlFor="reason">Reason for cancelling</label>
        <input id="reason" maxLength={200} value={reason} onChange={(e) => setReason(e.target.value)} />
        {error && <p className="error-message">{error}</p>}
        <div className="page-actions">
          <button type="button" className="danger-button" onClick={confirmCancel}>Cancel this appointment</button>
          <button type="button" onClick={backToList}>Keep it</button>
        </div>
      </div>
    )
  }

  return (
    <div className="my-appointments">
      <h2>My appointments</h2>

      <div className="page-actions">
        <button type="button" className={view === 'upcoming' ? 'active' : ''} onClick={() => setView('upcoming')}>
          Upcoming ({upcoming.length})
        </button>
        <button type="button" className={view === 'past' ? 'active' : ''} onClick={() => setView('past')}>
          Past and cancelled ({past.length})
        </button>
      </div>

      {message && <p className="success-message">{message}</p>}
      {error && <p className="error-message">{error}</p>}

      {view === 'upcoming' && loaded && (
        upcoming.length === 0 ? (
          <div className="panel">
            <p>You have no upcoming appointments.</p>
            <button type="button" className="primary-button" onClick={onBook}>Book an appointment</button>
          </div>
        ) : (
          <table className="data-table">
            <thead>
              <tr><th>Date / time</th><th>Doctor</th><th>Office</th><th>Cost</th><th></th></tr>
            </thead>
            <tbody>
              {upcoming.map((a) => (
                <tr key={a.appointmentID}>
                  <td>{formatDateTime(a.appointmentDateTime)}</td>
                  <td>{a.doctorName}</td>
                  <td>{a.officeAddress}</td>
                  <td>${Number(a.totalCost).toFixed(2)}</td>
                  <td><button type="button" onClick={() => startCancel(a)}>Cancel</button></td>
                </tr>
              ))}
            </tbody>
          </table>
        )
      )}

      {view === 'past' && loaded && (
        past.length === 0 ? (
          <p>No past appointments yet.</p>
        ) : (
          <table className="data-table">
            <thead>
              <tr><th>Date / time</th><th>Doctor</th><th>Office</th><th>Cost</th><th>Status</th></tr>
            </thead>
            <tbody>
              {past.map((a) => (
                <tr key={a.appointmentID}>
                  <td>{formatDateTime(a.appointmentDateTime)}</td>
                  <td>{a.doctorName}</td>
                  <td>{a.officeAddress}</td>
                  <td>${Number(a.totalCost).toFixed(2)}</td>
                  <td>
                    {a.appointStatus}
                    {a.cancelReason && <div className="cancel-note">{a.cancelledBy}: {a.cancelReason}</div>}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )
      )}
    </div>
  )
}
