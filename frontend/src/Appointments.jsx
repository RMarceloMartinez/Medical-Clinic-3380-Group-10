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
  const [view, setView] = useState('list')
  const [appointments, setAppointments] = useState([])
  const [error, setError] = useState('')
  const [message, setMessage] = useState('')
  const [filters, setFilters] = useState({ doctorId: '', patientId: '', from: '', to: '', status: '' })
  const [form, setForm] = useState(emptyForm)
  const [editingId, setEditingId] = useState(null)
  const [cancelId, setCancelId] = useState(null)
  const [cancelReason, setCancelReason] = useState('')
  const [cancelledBy, setCancelledBy] = useState('Patient')
  const [lookups, setLookups] = useState({ doctors: [], patients: [], offices: [] })

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

    async function loadLookups() {
    try {
      const [doctors, patients, offices] = await Promise.all([
        api.get('/lookups/doctors'),
        api.get('/lookups/patients'),
        api.get('/lookups/offices'),
      ])
      setLookups({ doctors, patients, offices })
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

  function openBookForm() {
    setMessage('')
    setError('')
    setCancelId(null)
    setEditingId(null)
    setForm(emptyForm)
    setView('form')
  }

  function backToList() {
    setError('')
    setEditingId(null)
    setForm(emptyForm)
    setView('list')
  }

  async function handleSave() {
    const body = toRequestBody(form)
    const ok = editingId
      ? await run(() => api.put(`/appointments/${editingId}`, body), `Appointment ${editingId} updated.`)
      : await run(() => api.post('/appointments', body), 'Appointment booked.')
    if (ok) {
      setEditingId(null)
      setForm(emptyForm)
      setView('list')
    }
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
    setView('form')
  }

  function startCancel(id) {
    setMessage('')
    setError('')
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
    loadLookups()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  return (
    <div className="appointments">
      <h2>Appointment Management</h2>

      <div className="appointments-menu">
        <button type="button" onClick={backToList}>View appointments</button>
        {canManage && (
          <button type="button" onClick={openBookForm}>Book appointment</button>
        )}
      </div>

      {error && <p className="error-message">{error}</p>}
      {message && <p className="success-message">{message}</p>}

      {view === 'list' && (
        <>
          <div className="filters">
            <select value={filters.doctorId} onChange={(e) => updateFilter('doctorId', e.target.value)}>
              <option value="">All doctors</option>
              {lookups.doctors.map((d) => (
                <option key={d.id} value={d.id}>{d.name}</option>
              ))}
            </select>
            <select value={filters.patientId} onChange={(e) => updateFilter('patientId', e.target.value)}>
              <option value="">All patients</option>
              {lookups.patients.map((p) => (
                <option key={p.id} value={p.id}>{p.name}</option>
              ))}
            </select>
            From <input type="date" value={filters.from}
              onChange={(e) => updateFilter('from', e.target.value)} />
            To <input type="date" value={filters.to}
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
                  <td>{a.patientName}</td>
                  <td>{a.doctorName}</td>
                  <td>{a.officeAddress}</td>
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
              <h3>Cancel appointment: {(() => {
                const a = appointments.find((x) => x.appointmentID === cancelId)
                return a ? `${a.patientName}, ${formatDateTime(a.appointmentDateTime)}` : cancelId
              })()}</h3>
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
        </>
      )}

      {view === 'form' && canManage && (
        <div className="appointment-form">
           <label>Patient</label>
          <select value={form.patientID} onChange={(e) => updateForm('patientID', e.target.value)}>
            <option value="">Select a patient</option>
            {lookups.patients.map((p) => (
              <option key={p.id} value={p.id}>{p.name}</option>
            ))}
          </select>
          <label>Doctor</label>
          <select value={form.doctorID} onChange={(e) => updateForm('doctorID', e.target.value)}>
            <option value="">Select a doctor</option>
            {lookups.doctors.map((d) => (
              <option key={d.id} value={d.id}>{d.name}</option>
            ))}
          </select>
          <label>Office</label>
          <select value={form.officeID} onChange={(e) => updateForm('officeID', e.target.value)}>
            <option value="">Select an office</option>
            {lookups.offices.map((o) => (
              <option key={o.id} value={o.id}>{o.name}</option>
            ))}
          </select>
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
          <button type="button" className="back-button" onClick={backToList}>
            Back to appointments
          </button>
        </div>
      )}
    </div>
  )
}