import { useEffect, useState } from 'react'
import { api } from '../../api/client'
import DataTable from '../../components/DataTable'
import SearchSelect from '../../components/SearchSelect'

function formatDate(value){
    return value? new Date(value).toLocaleDateString([], {month: 'short', day: 'numeric', year: 'numeric'}): ''
}

const columns = [
    {key: 'patientName', label: 'Patient'},
    {key: 'specialistName', label: 'Specialist'},
    {key: 'specialty', label: 'Specialty'},
    {key: 'dateIssued', label: 'Date', format: (r) => formatDate(r.dateIssued), sortValue: (r) => r.dateIssued},
    {key: 'refStatus', label: 'Status'},
]

export default function Referrals(){
    const[patients, setPatients] = useState([])
    const[specialists, setSpecialists] = useState([])
    const [sent, setSent] = useState([])
    const [patientId, setPatientId] = useState(null)
    const [specialistId, setSpecialistId] = useState('')
    const [pickerKey, setPickerKey] = useState(0)
    const [loading, setLoading] = useState(true)
    const [saving, setSaving] = useState(false)
    const [error, setError] = useState('')
    const [message, setMessage] = useState('')

    async function loadSent() {
    setSent(await api.get('/referrals'))
}

useEffect(() => {
    async function loadAll() {
      try {
        const [myPatients, allSpecialists, mySent] = await Promise.all([
          api.get('/referrals/patients'),
          api.get('/referrals/specialists'),
          api.get('/referrals'),
        ])
        setPatients(myPatients)
        setSpecialists(allSpecialists)
        setSent(mySent)
      } catch (e) {
        setError(`Could not load referrals: ${e.message}`)
      } finally {
        setLoading(false)
      }
    }
    loadAll()
  }, [])

  async function handleSend() {
    if (saving) return
    setError('')
    setMessage('')

    if (patientId == null) {
      setError('Choose a patient from the list.')
      return
    }
    if (!specialistId) {
      setError('Choose a specialist.')
      return
    }

    setSaving(true)
    try {
      await api.post('/referrals', { patientID: patientId, specialistID: Number(specialistId) })

      const patient = patients.find((p) => p.id === patientId)
      const specialist = specialists.find((s) => s.id === Number(specialistId))
      setMessage(`Referral sent: ${patient.name.split(' (')[0]} to Dr. ${specialist.name}, ${formatDate(new Date())}.`)

      setPatientId(null)
      setSpecialistId('')
      setPickerKey((k) => k + 1)      // new key → React makes a fresh, empty SearchSelect
      await loadSent()                // show the new referral in the list
    } catch (e) {
      setError(e.message)
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="referrals-page">
      <h2>Referrals</h2>

      <div className="panel panel-wide">
        <h2>Send a referral</h2>

        <div className="form-grid">
          <div className="form-field">
            <label htmlFor="ref-patient">Patient</label>
            <SearchSelect
              key={pickerKey}
              id="ref-patient"
              options={patients}
              value={patientId}
              onChange={setPatientId}
            />
          </div>
          <div className="form-field">
            <label htmlFor="ref-specialist">Specialist</label>
            <select id="ref-specialist" value={specialistId} onChange={(e) => setSpecialistId(e.target.value)}>
              <option value="">Select a specialist</option>
              {specialists.map((s) => (
                <option key={s.id} value={s.id}>Dr. {s.name}</option>
              ))}
            </select>
          </div>
        </div>

        <p className="field-hint">You can refer only patients you are the primary doctor for.</p>

        {message && <p className="success-message">{message}</p>}
        {error && <p role="alert" className="error-message">{error}</p>}

        <div className="page-actions">
          <button type="button" className="primary-button" onClick={handleSend} disabled={saving}>
            {saving ? 'Sending…' : 'Send referral'}
          </button>
        </div>
      </div>

      <h3>Referrals I sent</h3>
      {loading ? (
        <p>Loading…</p>
      ) : (
        <DataTable
          columns={columns}
          rows={sent}
          rowKey={(r) => r.referralID}
          filterLabel="Filter referrals"
          emptyMessage="You haven't sent any referrals yet."
        />
      )}
    </div>
  )
}