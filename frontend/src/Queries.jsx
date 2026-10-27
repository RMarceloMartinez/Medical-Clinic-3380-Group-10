import { useEffect, useState } from 'react'
import { api } from './api'

// Q1 doctor's week, Q2 patient balance, Q3 patient search
export default function Queries({ role }) {
  const canSeeBalance = role === 'Admin' || role === 'Receptionist'

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
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [hasRun, setHasRun] = useState(false)

  // dropdowns for Q1 and Q2
  useEffect(() => {
    async function loadLookups() {
      try {
        const [doctorList, patientList] = await Promise.all([
          api.get('/lookups/doctors'),
          api.get('/lookups/patients'),
        ])
        setDoctors(doctorList)
        setPatients(patientList)
      } catch (e) {
        setError(`Could not load the dropdowns: ${e.message}`)
      }
    }
    loadLookups()
  }, [])

  function pickQuery(value) {
    setQuery(value)
    setRows([])
    setBalance(null)
    setError('')
    setHasRun(false)
  }

  async function runQuery() {
    setError('')
    setRows([])
    setBalance(null)
    setHasRun(false)

    let url

    if (query === 'search') {
      const params = new URLSearchParams()
      if (name.trim() !== '') params.append('name', name.trim())
      if (dateOfBirth !== '') params.append('dateOfBirth', dateOfBirth)
      url = `/queries/patients?${params}`
    } else if (query === 'balance') {
      if (patientId === '') {
        setError('Pick a patient.')
        return
      }
      url = `/queries/balance?patientId=${patientId}`
    } else {
      if (doctorId === '' || weekStart === '') {
        setError('Pick a doctor and the first day of the week.')
        return
      }
      url = `/queries/doctor-week?doctorId=${doctorId}&weekStart=${weekStart}`
    }

    setLoading(true)
    try {
      const data = await api.get(url)
      if (query === 'balance') {
        setBalance(data)
      } else {
        setRows(data)
      }
      setHasRun(true)
    } catch (e) {
      setError(e.message)
    } finally {
      setLoading(false)
    }
  }

  const choices = [
    ['search', 'Search patients'],
    ...(canSeeBalance ? [['balance', 'Patient balance']] : []),
    ['doctor-week', "Doctor's week"],
  ]

  return (
    <div className="queries">
      <h2>Clinic Queries</h2>

      <div className="report-picker">
        {choices.map(([value, label]) => (
          <button key={value} disabled={loading} onClick={() => pickQuery(value)}>
            {label}
          </button>
        ))}
      </div>

      {query === 'search' && (
        <div className="filters">
          <p>Search by name, date of birth, or both. Leave both empty to list every patient.</p>
          Name <input value={name} onChange={(e) => setName(e.target.value)} placeholder="e.g. gar" />
          Date of birth <input type="date" value={dateOfBirth} onChange={(e) => setDateOfBirth(e.target.value)} />
        </div>
      )}

      {query === 'balance' && (
        <div className="filters">
          Patient{' '}
          <select value={patientId} onChange={(e) => setPatientId(e.target.value)}>
            <option value="">Select a patient</option>
            {patients.map((p) => (
              <option key={p.id} value={p.id}>{p.name}</option>
            ))}
          </select>
        </div>
      )}

      {query === 'doctor-week' && (
        <div className="filters">
          Doctor{' '}
          <select value={doctorId} onChange={(e) => setDoctorId(e.target.value)}>
            <option value="">Select a doctor</option>
            {doctors.map((d) => (
              <option key={d.id} value={d.id}>{d.name}</option>
            ))}
          </select>
          {' '}Week starting <input type="date" value={weekStart} onChange={(e) => setWeekStart(e.target.value)} />
        </div>
      )}

      <button onClick={runQuery} disabled={loading}>
        {loading ? 'Running…' : 'Run query'}
      </button>

      {error && <p className="error-message">{error}</p>}

      {query === 'search' && rows.length > 0 && (
        <table>
          <thead>
            <tr><th>Patient ID</th><th>Name</th><th>Date of birth</th><th>Phone</th></tr>
          </thead>
          <tbody>
            {rows.map((r) => (
              <tr key={r.patientID}>
                <td>{r.patientID}</td>
                <td>{r.patientName}</td>
                <td>{r.dateOfBirth}</td>
                <td>{r.phone}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      {query === 'balance' && balance && (
        <table>
          <thead>
            <tr><th>Billed (completed visits)</th><th>Paid</th><th>Balance</th></tr>
          </thead>
          <tbody>
            <tr>
              <td>${balance.billed.toFixed(2)}</td>
              <td>${balance.paid.toFixed(2)}</td>
              <td>${balance.balance.toFixed(2)}</td>
            </tr>
          </tbody>
        </table>
      )}

      {query === 'doctor-week' && rows.length > 0 && (
        <table>
          <thead>
            <tr><th>Date and time</th><th>Patient</th><th>Office</th><th>Status</th></tr>
          </thead>
          <tbody>
            {rows.map((r, index) => (
              <tr key={`${r.date_Time}-${index}`}>
                <td>{new Date(r.date_Time).toLocaleString()}</td>
                <td>{r.patientName}</td>
                <td>{r.office}</td>
                <td>{r.appointStatus}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      {hasRun && query !== 'balance' && rows.length === 0 && !error && <p>No results found.</p>}
    </div>
  )
}