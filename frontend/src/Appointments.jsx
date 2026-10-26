import { useEffect, useState } from 'react'
import { api } from './api'

function formatDateTime(value) {
  return new Date(value).toLocaleString([], { dateStyle: 'medium', timeStyle: 'short' })
}

const emptyForm = {
  patientID: '',
  doctorID: '',
  officeID: '',
  referralID: '',
  appointmentDateTime: '',
  totalCost: '',
  channel: 'Phone',
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

export default function Appointments({ role }) {
  const [appointments, setAppointments] = useState([])
  const [error, setError] = useState('')
  const [message, setMessage] = useState('')
  const [filters, setFilters] = useState({ doctorId: '', patientId: '', from: '', to: '', status: '' })
  const [form, setForm] = useState(emptyForm)
  const [editingId, setEditingId] = useState(null)
  const [cancelId, setCancelId] = useState(null)
  const [cancelReason, setCancelReason] = useState('')
  const [cancelledBy, setCancelledBy] = useState('Patient')

  const canManage = role === 'Admin' || role === 'Receptionist'
  const isDoctor = role === 'Doctor'
  const isAdmin = role === 'Admin'

  function updateFilter(field, value) {
    setFilters({ ...filters, [field]: value })
  }

  function updateForm(field, value) {
    setForm({ ...form, [field]: value })
  }

  async function loadAppointments() {
    setError('')
    try {
      const params = new URLSearchParams()
      Object.entries(filters).forEach(([key, value]) => {
        if (value !== '') params.append(key, value)
      })
      const data = await api.get(`/appointments?${params}`)
      setAppointments(data)
    } catch (e) {
      setError(e.message)
    }
  }

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

  async function handleSave() {
    const body = toRequestBody(form)
    const ok = editingId
      ? await run(() => api.put(`/appointments/${editingId}`, body), `Appointment ${editingId} updated.`)
      : await run(() => api.post('/appointments', body), 'Appointment booked.')
    if (ok) stopEditing()
  }

  function startEdit(a) {
    setMessage('')
    setError('')
    setCancelId(null)
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
  }

  function stopEditing() {
    setEditingId(null)
    setForm(emptyForm)
  }

  function startCancel(id) {
    setMessage('')
    setError('')
    stopEditing()
    setCancelId(id)
    setCancelReason('')
    setCancelledBy('Patient')
  }

  async function handleCancel() {
    const ok = await run(
      () => api.post(`/appointments/${cancelId}/cancel`, { cancelReason, cancelledBy }),
      `Appointment ${cancelId} cancelled.`)
    if (ok) setCancelId(null)
  }

  function handleComplete(id) {
    run(() => api.post(`/appointments/${id}/complete`), `Appointment ${id} completed.`)
  }

  function handleDelete(id) {
    if (!window.confirm(`Delete appointment ${id}? It will be hidden from every list.`)) return
    run(() => api.delete(`/appointments/${id}`), `Appointment ${id} deleted.`)
  }

  useEffect(() => {
    loadAppointments()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  return (
    <div className="appointments">
      <h2>Appointment Management</h2>
      <p>Logged in as: {role}</p>
      {error && <p className="error-message">{error}</p>}
      {message && <p className="success-message">{message}</p>}

      <div className="filters">
        <input placeholder="Doctor ID" value={filters.doctorId}
          onChange={(e) => updateFilter('doctorId', e.target.value)} />
        <input placeholder="Patient ID" value={filters.patientId}
          onChange={(e) => updateFilter('patientId', e.target.value)} />
        <input type="date" value={filters.from}
          onChange={(e) => updateFilter('from', e.target.value)} />
        <input type="date" value={filters.to}
          onChange={(e) => updateFilter('to', e.target.value)} />
        <select value={filters.status} onChange={(e) => updateFilter('status', e.target.value)}>
          <option value="">All statuses</option>
          <option value="Scheduled">Scheduled</option>
          <option value="Completed">Completed</option>
          <option value="Cancelled">Cancelled</option>
        </select>
        <button type="button" onClick={loadAppointments}>Search</button>
      </div>

      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Date / time</th>
            <th>Patient</th>
            <th>Doctor</th>
            <th>Office</th>
            <th>Cost</th>
            <th>Channel</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {appointments.map((a) => (
            <tr key={a.appointmentID}>
              <td>{a.appointmentID}</td>
              <td>{formatDateTime(a.appointmentDateTime)}</td>
              <td>{a.patientID}</td>
              <td>{a.doctorID}</td>
              <td>{a.officeID}</td>
              <td>${Number(a.totalCost).toFixed(2)}</td>
              <td>{a.channel}</td>
              <td>
                {a.appointStatus}
                {a.cancelReason && <div className="cancel-note">{a.cancelledBy}: {a.cancelReason}</div>}
              </td>
              <td>
                {a.appointStatus === 'Scheduled' && canManage && (
                  <>
                    <button type="button" onClick={() => startEdit(a)}>Edit</button>
                    <button type="button" onClick={() => startCancel(a.appointmentID)}>Cancel</button>
                  </>
                )}
                {a.appointStatus === 'Scheduled' && isDoctor && (
                  <button type="button" onClick={() => handleComplete(a.appointmentID)}>Complete</button>
                )}
                {isAdmin && (
                  <button type="button" onClick={() => handleDelete(a.appointmentID)}>Delete</button>
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      {appointments.length === 0 && !error && <p>No appointments found.</p>}

      {cancelId && (
        <div className="cancel-box">
          <h3>Cancel appointment {cancelId}</h3>
          <label>Reason</label>
          <input maxLength={200} value={cancelReason}
            onChange={(e) => setCancelReason(e.target.value)} />
          <label>Cancelled by</label>
          <select value={cancelledBy} onChange={(e) => setCancelledBy(e.target.value)}>
            <option value="Patient">Patient</option>
            <option value="Doctor">Doctor</option>
            <option value="Staff">Staff</option>
          </select>
          <button type="button" onClick={handleCancel}>Confirm cancellation</button>
          <button type="button" className="back-button" onClick={() => setCancelId(null)}>
            Keep appointment
          </button>
        </div>
      )}

      {canManage && (
        <div className="appointment-form">
          <h3>{editingId ? `Edit appointment ${editingId}` : 'Book an appointment'}</h3>
          <label>Patient ID</label>
          <input value={form.patientID} onChange={(e) => updateForm('patientID', e.target.value)} />
          <label>Doctor ID</label>
          <input value={form.doctorID} onChange={(e) => updateForm('doctorID', e.target.value)} />
          <label>Office ID</label>
          <input value={form.officeID} onChange={(e) => updateForm('officeID', e.target.value)} />
          <label>Referral ID (specialist visits only)</label>
          <input value={form.referralID} onChange={(e) => updateForm('referralID', e.target.value)} />
          <label>Date and time</label>
          <input type="datetime-local" value={form.appointmentDateTime}
            onChange={(e) => updateForm('appointmentDateTime', e.target.value)} />
          <label>Total cost ($)</label>
          <input type="number" min="0" step="0.01" value={form.totalCost}
            onChange={(e) => updateForm('totalCost', e.target.value)} />
          <label>Channel</label>
          <select value={form.channel} onChange={(e) => updateForm('channel', e.target.value)}>
            <option value="Phone">Phone</option>
            <option value="Web Portal">Web Portal</option>
          </select>
          <button type="button" onClick={handleSave}>
            {editingId ? 'Save changes' : 'Book appointment'}
          </button>
          {editingId && (
            <button type="button" className="back-button" onClick={stopEditing}>Stop editing</button>
          )}
        </div>
      )}
    </div>
  )
}