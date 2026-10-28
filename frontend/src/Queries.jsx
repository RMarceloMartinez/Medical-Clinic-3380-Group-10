import { useEffect, useState } from 'react'
import { api } from './api'
import './Queries.css'

// Q1 patient search, Q2 patient balance, Q3 doctor's week.
// Same layout as Reports: pick a query, fill the filter card, Run query, see the result.
const money = (n) =>
  Number(n ?? 0).toLocaleString('en-US', { style: 'currency', currency: 'USD' })

function formatDay(value) {
  return new Date(value).toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' })
}

function formatTime(value) {
  return new Date(value).toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' })
}

export default function Queries({ role }) {
  const canSeeBalance = role === 'Admin' || role === 'Receptionist'

  const choices = [
    ['search', 'Search patients'],
    ...(canSeeBalance ? [['balance', 'Patient balance']] : []),
    ['doctor-week', "Doctor's week"],
  ]

  const [query, setQuery] = useState('search')
  const [doctors, setDoctors] = useState([])
  const [patients, setPatients] = useState([])

  // inputs
  const [name, setName] = useState('')
  const [dateOfBirth, setDateOfBirth] = useState('')
  const [patientId, setPatientId] = useState('')
  const [doctorId, setDoctorId] = useState('')
  const [weekStart, setWeekStart] = useState('')

  // results
  const [rows, setRows] = useState([])
  const [balance, setBalance] = useState(null)
  const [hasRun, setHasRun] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  // dropdowns for the balance and doctor's week queries
  useEffect(() => {
    Promise.all([api.get('/lookups/doctors'), api.get('/lookups/patients')])
      .then(([doctorList, patientList]) => {
        setDoctors(doctorList)
        setPatients(patientList)
      })
      .catch((e) => setError(`Could not load the dropdowns: ${e.message}`))
  }, [])

  // Any change to the query or its inputs clears the old result
  function clearResult() {
    setRows([])
    setBalance(null)
    setHasRun(false)
    setError('')
  }

  function pickQuery(value) {
    setQuery(value)
    clearResult()
  }

  // Wraps a setter so typing in a field also clears the old result
  function onInput(setter) {
    return (e) => { setter(e.target.value); clearResult() }
  }

  async function runQuery() {
    clearResult()

    let url
    if (query === 'search') {
      const params = new URLSearchParams()
      if (name.trim() !== '') params.append('name', name.trim())
      if (dateOfBirth !== '') params.append('dateOfBirth', dateOfBirth)
      url = `/queries/patients?${params}`
    } else if (query === 'balance') {
      if (patientId === '') {
        setError('Please pick a patient.')
        return
      }
      url = `/queries/balance?patientId=${patientId}`
    } else {
      if (doctorId === '' || weekStart === '') {
        setError('Please pick a doctor and the first day of the week.')
        return
      }
      url = `/queries/doctor-week?doctorId=${doctorId}&weekStart=${weekStart}`
    }

    setLoading(true)
    try {
      const data = await api.get(url)
      if (query === 'balance') setBalance(data)
      else setRows(data)
      setHasRun(true)
    } catch (e) {
      setError(`Could not run the query: ${e.message}`)
    } finally {
      setLoading(false)
    }
  }

  const hints = {
    search: 'Search by name, date of birth, or both. Leave both empty to list every patient.',
    balance: 'Pick a patient to see what they were billed, what they paid, and what they still owe.',
    'doctor-week': "Pick a doctor and a start date to see their appointments for the next 7 days.",
  }

  const selectedPatient = patients.find((p) => String(p.id) === String(patientId))
  const selectedDoctor = doctors.find((d) => String(d.id) === String(doctorId))

  return (
    <div className="queries-page">
      <h2>Clinic Queries</h2>

      <div className="page-actions query-tabs">
        {choices.map(([value, label]) => (
          <button
            key={value}
            type="button"
            className={query === value ? 'active' : ''}
            aria-pressed={query === value}
            disabled={loading}
            onClick={() => pickQuery(value)}
          >
            {label}
          </button>
        ))}
      </div>

      <div className="filter-bar">
        {query === 'search' && (
          <>
            <div className="filter-field">
              <label htmlFor="q-name">Name</label>
              <input id="q-name" value={name} placeholder="e.g. Garcia" disabled={loading}
                onChange={onInput(setName)}
                onKeyDown={(e) => { if (e.key === 'Enter') runQuery() }} />
            </div>
            <div className="filter-field">
              <label htmlFor="q-dob">Date of birth</label>
              <input id="q-dob" type="date" value={dateOfBirth} disabled={loading}
                onChange={onInput(setDateOfBirth)} />
            </div>
          </>
        )}

        {query === 'balance' && (
          <div className="filter-field">
            <label htmlFor="q-patient">Patient</label>
            <select id="q-patient" value={patientId} disabled={loading} onChange={onInput(setPatientId)}>
              <option value="">Select a patient</option>
              {patients.map((p) => (
                <option key={p.id} value={p.id}>{p.name}</option>
              ))}
            </select>
          </div>
        )}

        {query === 'doctor-week' && (
          <>
            <div className="filter-field">
              <label htmlFor="q-doctor">Doctor</label>
              <select id="q-doctor" value={doctorId} disabled={loading} onChange={onInput(setDoctorId)}>
                <option value="">Select a doctor</option>
                {doctors.map((d) => (
                  <option key={d.id} value={d.id}>{d.name}</option>
                ))}
              </select>
            </div>
            <div className="filter-field">
              <label htmlFor="q-week">Week starting</label>
              <input id="q-week" type="date" value={weekStart} disabled={loading}
                onChange={onInput(setWeekStart)} />
            </div>
          </>
        )}

        <div className="filter-buttons">
          <button type="button" className="primary-button" onClick={runQuery} disabled={loading}>
            {loading ? 'Running…' : 'Run query'}
          </button>
        </div>
      </div>

      {error && <p className="error-message">{error}</p>}

      {!hasRun && !error && <p className="query-hint">{hints[query]}</p>}

      {hasRun && query !== 'balance' && rows.length === 0 && (
        <p className="query-hint">No results found.</p>
      )}

      {/* ---- Q1 Search patients ---- */}
      {query === 'search' && rows.length > 0 && (
        <>
          <p className="list-summary">
            {rows.length} {rows.length === 1 ? 'patient' : 'patients'} found
          </p>
          <div className="query-table-card">
            <table className="data-table query-table">
              <thead>
                <tr>
                  <th>Patient</th>
                  <th>Date of birth</th>
                  <th>Phone</th>
                </tr>
              </thead>
              <tbody>
                {rows.map((r) => (
                  <tr key={r.patientID}>
                    <td>
                      <div className="cell-main">{r.patientName}</div>
                      <div className="cell-sub">ID {r.patientID}</div>
                    </td>
                    <td>{r.dateOfBirth}</td>
                    <td>{r.phone}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      )}

      {/* ---- Q2 Patient balance ---- */}
      {query === 'balance' && balance && (
        <>
          {selectedPatient && (
            <h3 className="query-section-title">{selectedPatient.name}</h3>
          )}
          <div className="query-stats">
            <div className="query-stat">
              <span className="query-stat-label">Billed (completed visits)</span>
              <span className="query-stat-value">{money(balance.billed)}</span>
            </div>
            <div className="query-stat">
              <span className="query-stat-label">Paid</span>
              <span className="query-stat-value">{money(balance.paid)}</span>
            </div>
            <div className={`query-stat ${Number(balance.balance) > 0 ? 'owes' : 'paid-up'}`}>
              <span className="query-stat-label">
                {Number(balance.balance) > 0 ? 'Still owes' : 'Balance'}
              </span>
              <span className="query-stat-value">{money(balance.balance)}</span>
            </div>
          </div>
          {Number(balance.balance) <= 0 && (
            <p className="query-hint">This patient is fully paid up.</p>
          )}
        </>
      )}

      {/* ---- Q3 Doctor's week ---- */}
      {query === 'doctor-week' && rows.length > 0 && (
        <>
          <p className="list-summary">
            {rows.length} {rows.length === 1 ? 'appointment' : 'appointments'}
            {selectedDoctor ? ` for ${selectedDoctor.name}` : ''}
          </p>
          <div className="query-table-card">
            <table className="data-table query-table">
              <thead>
                <tr>
                  <th>Day</th>
                  <th>Time</th>
                  <th>Patient</th>
                  <th>Office</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                {rows.map((r, index) => (
                  <tr key={`${r.date_Time}-${index}`}>
                    <td className="cell-main">{formatDay(r.date_Time)}</td>
                    <td>{formatTime(r.date_Time)}</td>
                    <td>{r.patientName}</td>
                    <td>{r.office}</td>
                    <td>
                      <span className={`status-badge ${String(r.appointStatus).toLowerCase()}`}>
                        {r.appointStatus}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      )}
    </div>
  )
}
