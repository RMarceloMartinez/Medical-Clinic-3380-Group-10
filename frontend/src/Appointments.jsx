import { useEffect, useState } from 'react'
import { api } from './api'

// Staff appointments page. One screen at a time:
//   'list'   = filters + table (+ Edit / Cancel / Complete / Delete per row)
//   'form'   = book a new appointment, or edit one (editingId set)
//   'cancel' = confirm one cancellation
const emptyFilters = { doctorId: '', patientId: '', from: '', to: '', status: '' }

const emptyForm = {
  patientID: '',
  doctorID: '',
  officeID: '',
  referralID: '',
  appointmentDateTime: '',
  totalCost: '',
  channel: 'Phone',
}

function formatDate(value) {
  return new Date(value).toLocaleDateString([], { weekday: 'short', month: 'short', day: 'numeric', year: 'numeric' })
}

function formatTime(value) {
  return new Date(value).toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' })
}

function formatDateTime(value) {
  return `${formatDate(value)}, ${formatTime(value)}`
}

function toRequestBody(form) {
  return {
    patientID: Number(form.patientID),
    doctorID: Number(form.doctorID),
    officeID: Number(form.officeID),
    referralID: form.referralID === '' ? null : Number(form.referralID),
    appointmentDateTime: form.appointmentDateTime,
    totalCost: Number(form.totalCost),
    channel: form.channel,
  }
}

function toQuery(filters) {
  const params = new URLSearchParams()
  Object.entries(filters).forEach(([key, value]) => {
    if (value !== '') params.append(key, value)   // empty = not sent = no filter
  })
  return `/appointments?${params}`
}

export default function Appointments({ role }) {
  const [view, setView] = useState('list')
  const [appointments, setAppointments] = useState([])
  const [loaded, setLoaded] = useState(false)
  const [error, setError] = useState('')
  const [message, setMessage] = useState('')
  const [filters, setFilters] = useState(emptyFilters)
  const [form, setForm] = useState(emptyForm)
  const [editingId, setEditingId] = useState(null)
  const [toCancel, setToCancel] = useState(null)
  const [cancelReason, setCancelReason] = useState('')
  const [cancelledBy, setCancelledBy] = useState('Patient')
  const [lookups, setLookups] = useState({ doctors: [], patients: [], offices: [] })

  const canManage = role === 'Admin' || role === 'Receptionist'
  const isDoctor = role === 'Doctor'
  const isAdmin = role === 'Admin'

  // First load: the list and the dropdown lists
  useEffect(() => {
    api.get(toQuery(emptyFilters))
      .then(setAppointments)
      .catch((e) => setError(e.message))
      .finally(() => setLoaded(true))

    Promise.all([
      api.get('/lookups/doctors'),
      api.get('/lookups/patients'),
      api.get('/lookups/offices'),
    ])
      .then(([doctors, patients, offices]) => setLookups({ doctors, patients, offices }))
      .catch((e) => setError(e.message))
  }, [])

  async function loadAppointments(currentFilters = filters) {
    setError('')
    try {
      setAppointments(await api.get(toQuery(currentFilters)))
    } catch (e) {
      setError(e.message)
    } finally {
      setLoaded(true)
    }
  }

  function updateFilter(field, value) {
    setFilters({ ...filters, [field]: value })
  }

  function clearFilters() {
    setFilters(emptyFilters)
    loadAppointments(emptyFilters)
  }

  function updateForm(field, value) {
    setForm({ ...form, [field]: value })
  }

  // Runs one API action, shows the result, reloads the list
  async function run(action, successText) {
    setMessage('')
    setError('')
    try {
      await action()
      setMessage(successText)
      await loadAppointments()
      return true
    } catch (e) {
      setError(e.message)
      return false
    }
  }

  function showList() {
    setError('')
    setEditingId(null)
    setToCancel(null)
    setForm(emptyForm)
    setView('list')
  }

  // ----- Book / edit -----
  function openBookForm() {
    setMessage('')
    showList()
    setView('form')
  }

  function startEdit(a) {
    setMessage('')
    setError('')
    setEditingId(a.appointmentID)
    setForm({
      patientID: String(a.patientID),
      doctorID: String(a.doctorID),
      officeID: String(a.officeID),
      referralID: a.referralID === null ? '' : String(a.referralID),
      appointmentDateTime: a.appointmentDateTime.slice(0, 16),
      totalCost: String(a.totalCost),
      channel: a.channel,
    })
    setView('form')
  }

  async function handleSave() {
    if (!form.patientID || !form.doctorID || !form.officeID || !form.appointmentDateTime || form.totalCost === '') {
      setError('Fill in the patient, doctor, office, date and time, and cost.')
      return
    }
    const body = toRequestBody(form)
    const ok = editingId
      ? await run(() => api.put(`/appointments/${editingId}`, body), 'Appointment updated.')
      : await run(() => api.post('/appointments', body), 'Appointment booked.')
    if (ok) showList()
  }

  // ----- Cancel -----
  function startCancel(a) {
    setMessage('')
    setError('')
    setToCancel(a)
    setCancelReason('')
    setCancelledBy('Patient')
    setView('cancel')
  }

  async function handleCancel() {
    if (cancelReason.trim() === '') {
      setError('Enter a reason for the cancellation.')
      return
    }
    const ok = await run(
      () => api.post(`/appointments/${toCancel.appointmentID}/cancel`, { cancelReason: cancelReason.trim(), cancelledBy }),
      `Cancelled ${toCancel.patientName}'s appointment on ${formatDateTime(toCancel.appointmentDateTime)}.`)
    if (ok) showList()
  }

  // ----- Complete / delete -----
  function handleComplete(a) {
    run(() => api.post(`/appointments/${a.appointmentID}/complete`),
      `Marked ${a.patientName}'s appointment as completed.`)
  }

  function handleDelete(a) {
    if (!window.confirm(`Delete ${a.patientName}'s appointment on ${formatDateTime(a.appointmentDateTime)}? It will be hidden from every list.`)) return
    run(() => api.delete(`/appointments/${a.appointmentID}`), 'Appointment deleted.')
  }

  const scheduledCount = appointments.filter((a) => a.appointStatus === 'Scheduled').length

  return (
    <div className="appointments-page">
      <h2>Appointments</h2>

      <div className="page-actions">
        <button type="button" className={view !== 'form' ? 'active' : ''} onClick={showList}>
          All appointments
        </button>
        {canManage && (
          <button type="button" className={view === 'form' && !editingId ? 'active' : ''} onClick={openBookForm}>
            Book appointment
          </button>
        )}
      </div>

      {message && <p className="success-message">{message}</p>}
      {error && view === 'list' && <p className="error-message">{error}</p>}

      {/* ---------- List ---------- */}
      {view === 'list' && (
        <>
          <div className="filter-bar">
            <div className="filter-field">
              <label htmlFor="f-doctor">Doctor</label>
              <select id="f-doctor" value={filters.doctorId} onChange={(e) => updateFilter('doctorId', e.target.value)}>
                <option value="">All doctors</option>
                {lookups.doctors.map((d) => (
                  <option key={d.id} value={d.id}>{d.name}</option>
                ))}
              </select>
            </div>
            <div className="filter-field">
              <label htmlFor="f-patient">Patient</label>
              <select id="f-patient" value={filters.patientId} onChange={(e) => updateFilter('patientId', e.target.value)}>
                <option value="">All patients</option>
                {lookups.patients.map((p) => (
                  <option key={p.id} value={p.id}>{p.name}</option>
                ))}
              </select>
            </div>
            <div className="filter-field">
              <label htmlFor="f-status">Status</label>
              <select id="f-status" value={filters.status} onChange={(e) => updateFilter('status', e.target.value)}>
                <option value="">All statuses</option>
                <option value="Scheduled">Scheduled</option>
                <option value="Completed">Completed</option>
                <option value="Cancelled">Cancelled</option>
              </select>
            </div>
            <div className="filter-field">
              <label htmlFor="f-from">From</label>
              <input id="f-from" type="date" value={filters.from} onChange={(e) => updateFilter('from', e.target.value)} />
            </div>
            <div className="filter-field">
              <label htmlFor="f-to">To</label>
              <input id="f-to" type="date" value={filters.to} onChange={(e) => updateFilter('to', e.target.value)} />
            </div>
            <div className="filter-buttons">
              <button type="button" className="primary-button" onClick={() => loadAppointments()}>Search</button>
              <button type="button" onClick={clearFilters}>Clear</button>
            </div>
          </div>

          {loaded && (
            <p className="list-summary">
              {appointments.length} appointment{appointments.length === 1 ? '' : 's'}
              {appointments.length > 0 && ` · ${scheduledCount} scheduled`}
            </p>
          )}

          {loaded && appointments.length === 0 && !error ? (
            <div className="panel">
              <p>No appointments match these filters.</p>
            </div>
          ) : (
            <table className="data-table appointments-table">
              <thead>
                <tr>
                  <th>Date</th>
                  <th>Patient</th>
                  <th>Doctor</th>
                  <th>Office</th>
                  <th>Cost</th>
                  <th>Status</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {appointments.map((a) => (
                  <tr key={a.appointmentID}>
                    <td>
                      <div className="cell-main">{formatDate(a.appointmentDateTime)}</div>
                      <div className="cell-sub">{formatTime(a.appointmentDateTime)} · {a.channel}</div>
                    </td>
                    <td>{a.patientName}</td>
                    <td>{a.doctorName}</td>
                    <td>{a.officeAddress}</td>
                    <td>${Number(a.totalCost).toFixed(2)}</td>
                    <td>
                      <span className={`status-badge ${a.appointStatus.toLowerCase()}`}>{a.appointStatus}</span>
                      {a.cancelReason && <div className="cell-sub">{a.cancelledBy}: {a.cancelReason}</div>}
                    </td>
                    <td className="row-actions">
                      {a.appointStatus === 'Scheduled' && canManage && (
                        <>
                          <button type="button" onClick={() => startEdit(a)}>Edit</button>
                          <button type="button" onClick={() => startCancel(a)}>Cancel</button>
                        </>
                      )}
                      {a.appointStatus === 'Scheduled' && isDoctor && (
                        <button type="button" onClick={() => handleComplete(a)}>Complete</button>
                      )}
                      {isAdmin && (
                        <button type="button" className="danger-link" onClick={() => handleDelete(a)}>Delete</button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </>
      )}

      {/* ---------- Book / edit ---------- */}
      {view === 'form' && canManage && (
        <div className="panel panel-wide">
          <h2>{editingId ? 'Edit appointment' : 'Book an appointment'}</h2>

          <div className="form-grid">
            <div className="form-field">
              <label htmlFor="patient">Patient</label>
              <select id="patient" value={form.patientID} onChange={(e) => updateForm('patientID', e.target.value)}>
                <option value="">Select a patient</option>
                {lookups.patients.map((p) => (
                  <option key={p.id} value={p.id}>{p.name}</option>
                ))}
              </select>
            </div>
            <div className="form-field">
              <label htmlFor="doctor">Doctor</label>
              <select id="doctor" value={form.doctorID} onChange={(e) => updateForm('doctorID', e.target.value)}>
                <option value="">Select a doctor</option>
                {lookups.doctors.map((d) => (
                  <option key={d.id} value={d.id}>{d.name}</option>
                ))}
              </select>
            </div>
            <div className="form-field">
              <label htmlFor="office">Office</label>
              <select id="office" value={form.officeID} onChange={(e) => updateForm('officeID', e.target.value)}>
                <option value="">Select an office</option>
                {lookups.offices.map((o) => (
                  <option key={o.id} value={o.id}>{o.name}</option>
                ))}
              </select>
            </div>
            <div className="form-field">
              <label htmlFor="when">Date and time</label>
              <input id="when" type="datetime-local" value={form.appointmentDateTime}
                onChange={(e) => updateForm('appointmentDateTime', e.target.value)} />
            </div>
            <div className="form-field">
              <label htmlFor="cost">Total cost ($)</label>
              <input id="cost" type="number" min="0" step="0.01" value={form.totalCost}
                onChange={(e) => updateForm('totalCost', e.target.value)} />
            </div>
            <div className="form-field">
              <label htmlFor="channel">Booked by</label>
              <select id="channel" value={form.channel} onChange={(e) => updateForm('channel', e.target.value)}>
                <option value="Phone">Phone</option>
                <option value="Web Portal">Web Portal</option>
              </select>
            </div>
          </div>

          <p className="field-hint">
            The doctor must work at that office on that weekday, within office hours. A specialist needs an open
            referral from the patient's primary doctor.
          </p>

          {error && <p className="error-message">{error}</p>}

          <div className="page-actions">
            <button type="button" className="primary-button" onClick={handleSave}>
              {editingId ? 'Save changes' : 'Book appointment'}
            </button>
            <button type="button" onClick={showList}>Back to appointments</button>
          </div>
        </div>
      )}

      {/* ---------- Cancel ---------- */}
      {view === 'cancel' && toCancel && (
        <div className="panel">
          <h2>Cancel appointment</h2>
          <p>
            <strong>{toCancel.patientName}</strong> with {toCancel.doctorName}<br />
            {formatDateTime(toCancel.appointmentDateTime)}<br />
            {toCancel.officeAddress}
          </p>

          <label htmlFor="reason">Reason</label>
          <input id="reason" maxLength={200} value={cancelReason} onChange={(e) => setCancelReason(e.target.value)} />

          <label htmlFor="by">Cancelled by</label>
          <select id="by" value={cancelledBy} onChange={(e) => setCancelledBy(e.target.value)}>
            <option value="Patient">Patient</option>
            <option value="Doctor">Doctor</option>
            <option value="Staff">Staff</option>
          </select>

          {error && <p className="error-message">{error}</p>}

          <div className="page-actions">
            <button type="button" className="danger-button" onClick={handleCancel}>Cancel this appointment</button>
            <button type="button" onClick={showList}>Keep it</button>
          </div>
        </div>
      )}
    </div>
  )
}