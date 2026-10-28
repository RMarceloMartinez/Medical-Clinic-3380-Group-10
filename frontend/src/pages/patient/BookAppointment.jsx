import { useEffect, useState } from 'react'
import { api } from '../../api/client'

const DAY_NAMES = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']

// "08:00-17:00" -> ['08:00', '08:30', ..., '16:30'] (last visit starts 30 min before closing)
function timeSlots(officeHours) {
  const [open, close] = officeHours.split('-')
  const toMinutes = (t) => Number(t.slice(0, 2)) * 60 + Number(t.slice(3, 5))
  const slots = []
  for (let m = toMinutes(open); m + 30 <= toMinutes(close); m += 30) {
    slots.push(`${String(Math.floor(m / 60)).padStart(2, '0')}:${String(m % 60).padStart(2, '0')}`)
  }
  return slots
}

function weekdayOf(dateText) {
  return DAY_NAMES[new Date(`${dateText}T00:00`).getDay()]   // 'Mon', 'Tue', ...
}

// Two screens: 1) pick a doctor + office, 2) pick a day and time, then book.
// The list comes from GET /api/me/doctors: the primary doctor, plus
// specialists this patient has an open referral to.
export default function BookAppointment({ onBooked }) {
  const [choices, setChoices] = useState([])
  const [loaded, setLoaded] = useState(false)
  const [choice, setChoice] = useState(null)
  const [date, setDate] = useState('')
  const [time, setTime] = useState('')
  const [error, setError] = useState('')
  const [busy, setBusy] = useState(false)

  useEffect(() => {
    api.get('/me/doctors')
      .then(setChoices)
      .catch((e) => setError(e.message))
      .finally(() => setLoaded(true))
  }, [])

  function pick(c) {
    setError('')
    setDate('')
    setTime('')
    setChoice(c)
  }

  const workDays = choice ? choice.workDays.split(', ') : []
  const wrongDay = date !== '' && choice && !workDays.includes(weekdayOf(date))

  async function handleBook() {
    setError('')
    if (date === '' || time === '') {
      setError('Pick a day and a time.')
      return
    }
    if (wrongDay) {
      setError(`${choice.doctorName} only works at this office on ${choice.workDays}.`)
      return
    }

    setBusy(true)
    try {
      await api.post('/me/appointments', {
        doctorID: choice.doctorID,
        officeID: choice.officeID,
        appointmentDateTime: `${date}T${time}:00`,
      })
      onBooked()                     // go to "My appointments", which shows the new visit
    } catch (e) {
      setError(e.message)            // e.g. a trigger message from the database
    } finally {
      setBusy(false)
    }
  }

  // ----- Screen 1: pick a doctor -----
  if (!choice) {
    return (
      <div className="book-page">
        <h2>Book an appointment</h2>
        <p>Choose who you want to see.</p>
        {error && <p className="error-message">{error}</p>}
        {loaded && choices.length === 0 && !error && (
          <p>No doctors are available for you to book right now. Please call the clinic.</p>
        )}
        <div className="home-cards">
          {choices.map((c) => (
            <button key={`${c.doctorID}-${c.officeID}`} type="button" className="home-card" onClick={() => pick(c)}>
              <span className="home-card-title">{c.doctorName}</span>
              <span className="home-card-text">
                {c.specialty}{c.referralID ? ' (referral)' : ' (your primary doctor)'}<br />
                {c.officeAddress}<br />
                {c.workDays}, {c.officeHours}<br />
                Visit fee: ${Number(c.visitFee).toFixed(2)}
              </span>
            </button>
          ))}
        </div>
      </div>
    )
  }

  // ----- Screen 2: pick a day and time -----
  return (
    <div className="panel">
      <h2>Book with {choice.doctorName}</h2>
      <p>
        {choice.specialty} · {choice.officeAddress}<br />
        Works here on <strong>{choice.workDays}</strong>, {choice.officeHours}
      </p>

      <label htmlFor="date">Day</label>
      <input
        id="date"
        type="date"
        min={new Date().toLocaleDateString('en-CA')}
        value={date}
        onChange={(e) => setDate(e.target.value)}
      />
      {wrongDay && (
        <p className="field-error">
          That is a {weekdayOf(date)}. Pick a {choice.workDays} instead.
        </p>
      )}

      <label htmlFor="time">Time</label>
      <select id="time" value={time} onChange={(e) => setTime(e.target.value)}>
        <option value="">Select a time</option>
        {timeSlots(choice.officeHours).map((t) => (
          <option key={t} value={t}>{t}</option>
        ))}
      </select>

      <p className="field-hint">Visit fee: ${Number(choice.visitFee).toFixed(2)}</p>

      {error && <p className="error-message">{error}</p>}

      <div className="page-actions">
        <button type="button" className="primary-button" onClick={handleBook} disabled={busy}>
          {busy ? 'Booking…' : 'Book appointment'}
        </button>
        <button type="button" onClick={() => setChoice(null)}>Choose another doctor</button>
      </div>
    </div>
  )
}
