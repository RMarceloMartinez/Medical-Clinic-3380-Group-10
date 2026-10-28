import { useEffect, useState } from 'react'
import { api } from '../../api/client'

// Payments (moved out of App.jsx). Two screens:
//   'record' = the payment form, 'recent' = payments recorded in this session
const METHODS = { 1: 'Cash', 2: 'Credit Card', 3: 'Debit Card', 4: 'Insurance', 5: 'Check' }

function today() {
  return new Date().toLocaleDateString('en-CA')   // yyyy-mm-dd
}

function appointmentLabel(a) {
  if (!a) return ''
  const when = new Date(a.appointmentDateTime).toLocaleString([], { dateStyle: 'short', timeStyle: 'short' })
  return `${a.patientName} with ${a.doctorName} — ${when} (${a.appointStatus})`
}

const emptyForm = { appointmentId: '', amount: '', date: today(), method: '', status: 'Completed', installment: '1' }

export default function Payments() {
  const [view, setView] = useState('record')
  const [appointments, setAppointments] = useState([])
  const [form, setForm] = useState(emptyForm)
  const [payments, setPayments] = useState([])
  const [error, setError] = useState('')
  const [message, setMessage] = useState('')
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    async function loadAppointments() {
      try {
        const result = await api.get('/appointments')
        // newest first, so recent visits are at the top of the dropdown
        result.sort((x, y) => new Date(y.appointmentDateTime) - new Date(x.appointmentDateTime))
        setAppointments(result)
      } catch (e) {
        setError(`Could not load appointments: ${e.message}`)
      }
    }
    loadAppointments()
  }, [])

  function update(field, value) {
    setForm({ ...form, [field]: value })
  }

  async function handleRecordPayment() {
    if (saving) return
    setError('')
    setMessage('')

    const amount = Number(form.amount)
    const installment = Number(form.installment)
    const methodId = Number(form.method)

    if (!/^[1-9]\d{6}$/.test(form.appointmentId)) {
      setError('Pick an appointment.')
      return
    }
    if (!/^\d+(\.\d{1,2})?$/.test(form.amount) || amount < 0.01 || amount > 99999999.99) {
      setError('Enter an amount from $0.01 to $99,999,999.99 with at most two decimal places.')
      return
    }
    if (!Number.isInteger(installment) || installment < 1 || installment > 2147483647) {
      setError('Enter a valid positive installment number.')
      return
    }
    if (!form.date || !METHODS[methodId] || !['Pending', 'Completed'].includes(form.status)) {
      setError('Select a payment date, method, and status.')
      return
    }

    const request = {
      appointmentID: Number(form.appointmentId),
      installmentNumber: installment,
      paymentDate: form.date,
      payStatus: form.status,
      details: [{ methodID: methodId, amountApplied: amount }],
    }

    setSaving(true)
    try {
      const result = await api.post('/payments', request)
      const appointment = appointments.find((a) => a.appointmentID === request.appointmentID)

      setPayments((previous) => [...previous, {
        paymentID: result.paymentID,
        appointment: appointmentLabel(appointment),
        amount,
        date: request.paymentDate,
        method: METHODS[methodId],
        status: request.payStatus,
      }])

      setForm({ ...emptyForm, date: today() })
      setMessage(`Payment of $${amount.toFixed(2)} recorded.`)
    } catch (e) {
      setError(e.message || 'Could not record payment.')
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="payments-page">
      <h2>Payments</h2>

      <div className="page-actions">
        <button type="button" className={view === 'record' ? 'active' : ''} onClick={() => setView('record')}>
          Record payment
        </button>
        <button type="button" className={view === 'recent' ? 'active' : ''} onClick={() => setView('recent')}>
          Recorded this session ({payments.length})
        </button>
      </div>

      {message && <p className="success-message">{message}</p>}

      {view === 'record' && (
        <div className="payment-form">
          <h2>Record Payment</h2>

          <label htmlFor="appointment">Appointment</label>
          <select id="appointment" value={form.appointmentId} onChange={(e) => update('appointmentId', e.target.value)}>
            <option value="">Select an appointment</option>
            {appointments.map((a) => (
              <option key={a.appointmentID} value={a.appointmentID}>{appointmentLabel(a)}</option>
            ))}
          </select>

          <label htmlFor="amount">Payment amount ($)</label>
          <input id="amount" type="number" placeholder="Enter amount" min="0" step="0.01"
            value={form.amount} onChange={(e) => update('amount', e.target.value)} />

          <label htmlFor="date">Payment date</label>
          <input id="date" type="date" value={form.date} onChange={(e) => update('date', e.target.value)} />

          <label htmlFor="method">Payment method</label>
          <select id="method" value={form.method} onChange={(e) => update('method', e.target.value)}>
            <option value="" disabled>Select payment method</option>
            {Object.entries(METHODS).map(([id, name]) => (
              <option key={id} value={id}>{name}</option>
            ))}
          </select>

          <label htmlFor="status">Payment status</label>
          <select id="status" value={form.status} onChange={(e) => update('status', e.target.value)}>
            <option value="Pending">Pending</option>
            <option value="Completed">Completed</option>
          </select>

          <label htmlFor="installment">Installment number</label>
          <input id="installment" type="number" min="1" max="2147483647" step="1"
            value={form.installment} onChange={(e) => update('installment', e.target.value)} />

          {error && <p role="alert" className="error-message">{error}</p>}

          <button type="button" onClick={handleRecordPayment} disabled={saving}>
            {saving ? 'Saving…' : 'Record payment'}
          </button>
        </div>
      )}

      {view === 'recent' && (
        <>
          <table className="data-table">
            <thead>
              <tr>
                <th>Appointment</th>
                <th>Amount</th>
                <th>Date</th>
                <th>Method</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              {payments.map((p) => (
                <tr key={p.paymentID}>
                  <td>{p.appointment}</td>
                  <td>${p.amount.toFixed(2)}</td>
                  <td>{p.date}</td>
                  <td>{p.method}</td>
                  <td>{p.status}</td>
                </tr>
              ))}
            </tbody>
          </table>
          {payments.length === 0 && <p>No payments recorded in this session yet.</p>}
        </>
      )}
    </div>
  )
}
