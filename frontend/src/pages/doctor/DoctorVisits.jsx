import { useEffect, useState } from 'react'
import { api } from '../../api/client'
import DataTable from '../../components/DataTable'

// Doctor "My visits" page. One screen at a time:
//   'list'  = the logged-in doctor's own visits (today / this week)
//   'visit' = one visit: the nurse's vitals (read only), the notes form,
//             and the "Save notes" / "Save and complete" buttons
// The doctor is identified by the server from the login, never sent from here.

const VITALS = [
  { key: 'systolicBP', label: 'Systolic BP', unit: 'mmHg' },
  { key: 'diastolicBP', label: 'Diastolic BP', unit: 'mmHg' },
  { key: 'heartRate', label: 'Heart rate', unit: 'bpm' },
  { key: 'temperature', label: 'Temperature', unit: '°F' },
  { key: 'weightPounds', label: 'Weight', unit: 'lb' },
  { key: 'heightInches', label: 'Height', unit: 'in' },
]

// Max lengths match the MedicalRecord columns
const NOTE_FIELDS = [
  { key: 'clinicalNotes', label: 'Clinical notes', max: 500, rows: 5 },
  { key: 'treatmentPlan', label: 'Treatment plan', max: 200, rows: 3 },
  { key: 'followUp', label: 'Follow-up', max: 200, rows: 3 },
]

const emptyNotes = { clinicalNotes: '', treatmentPlan: '', followUp: '' }

// Prescription form. Max lengths match the Prescription columns.
const RX_FIELDS = [
  { key: 'medicationName', label: 'Medication', max: 50, placeholder: 'e.g. Amoxicillin' },
  { key: 'dosage', label: 'Dosage', max: 20, placeholder: 'e.g. 500 mg' },
  { key: 'frequency', label: 'How often', max: 20, placeholder: 'e.g. Twice a day' },
  { key: 'duration', label: 'For how long', max: 20, placeholder: 'e.g. 7 days' },
  { key: 'instructions', label: 'Instructions (optional)', max: 100, placeholder: 'e.g. Take with food' },
]

const PHARMACIES = [
  'CVS Pharmacy, Main Street',
  'Walgreens, Westheimer Road',
  'H-E-B Pharmacy, Richmond Avenue',
  'Clarity Health Pharmacy, Main Street',
]

const emptyRx = { medicationName: '', dosage: '', frequency: '', duration: '', instructions: '', pharmacy: '' }

// checks api's central local time and current central time
// (same check as the Complete button on the Appointments page)
function hasAppointmentStarted(value) {
  if (!value) return false

  const parts = new Intl.DateTimeFormat('en-US', {
    timeZone: 'America/Chicago',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hourCycle: 'h23',
  }).formatToParts(new Date())

  const fields = Object.fromEntries(
    parts.map(({ type, value }) => [type, value])
  )

  const centralNow =
    `${fields.year}-${fields.month}-${fields.day}` +
    `T${fields.hour}:${fields.minute}:${fields.second}`

  return value <= centralNow
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

// "Nov 11 at 10:00 AM", used in the success messages
function formatWhen(value) {
  const day = new Date(value).toLocaleDateString([], { month: 'short', day: 'numeric' })
  return `${day} at ${formatTime(value)}`
}

export default function DoctorVisits() {
  const [view, setView] = useState('list')
  const [range, setRange] = useState('today') // 'today' | 'week'
  const [visits, setVisits] = useState([])
  const [loaded, setLoaded] = useState(false)
  const [error, setError] = useState('')
  const [message, setMessage] = useState('')
  const [selected, setSelected] = useState(null) // the visit that is open
  const [record, setRecord] = useState(null)     // the nurse's vitals + saved notes
  const [loadingRecord, setLoadingRecord] = useState(false)
  const [notes, setNotes] = useState(emptyNotes)
  const [saving, setSaving] = useState(false)
  const [rx, setRx] = useState(emptyRx)          // the prescription form
  const [rxWarning, setRxWarning] = useState('') // allergy warning waiting for the doctor's answer
  const [rxError, setRxError] = useState('')
  const [rxSaving, setRxSaving] = useState(false)

  // First load
  useEffect(() => {
    loadVisits('today')
  }, [])

  async function loadVisits(currentRange = range) {
    setError('')
    try {
      setVisits(await api.get(`/doctor/visits?range=${currentRange}`))
    } catch (e) {
      setError(e.message)
    } finally {
      setLoaded(true)
    }
  }

  function changeRange(next) {
    setRange(next)
    setLoaded(false)
    loadVisits(next)
  }

  // Back to the list. It reloads, so a visit the nurse just recorded shows up as "Recorded".
  function showList() {
    setError('')
    setSelected(null)
    setRecord(null)
    setNotes(emptyNotes)
    resetRx()
    setView('list')
    loadVisits()
  }

  // ----- Open a visit -----
  async function startVisit(visit) {
    setMessage('')
    setError('')
    setSelected(visit)
    setRecord(null)
    setNotes(emptyNotes)
    resetRx()
    setView('visit')

    // No vitals yet: nothing to load, and the form stays disabled
    if (!visit.vitalsRecorded) return

    setLoadingRecord(true)
    try {
      const saved = await api.get(`/doctor/appointments/${visit.appointmentID}/record`)
      setRecord(saved)
      setNotes({
        clinicalNotes: saved.clinicalNotes ?? '',
        treatmentPlan: saved.treatmentPlan ?? '',
        followUp: saved.followUp ?? '',
      })
    } catch (e) {
      setError(e.message)
    } finally {
      setLoadingRecord(false)
    }
  }

  // ----- Save notes (and optionally complete the visit) -----
  async function handleSave(andComplete) {
    setSaving(true)
    setError('')
    setMessage('')
    const when = formatWhen(selected.appointmentDateTime)

    try {
      await api.put(`/doctor/appointments/${selected.appointmentID}/notes`, notes)
    } catch (e) {
      setError(e.message)
      setSaving(false)
      return
    }

    if (!andComplete) {
      setMessage(`Notes saved for ${selected.patientName}, ${when}.`)
      setSaving(false)
      return
    }

    try {
      await api.post(`/appointments/${selected.appointmentID}/complete`)
    } catch (e) {
      // The notes are already saved; only completing the visit failed
      setError(`Notes were saved, but the visit was not completed: ${e.message}`)
      setSaving(false)
      return
    }

    setMessage(`Notes saved and visit completed for ${selected.patientName}, ${when}.`)
    setSaving(false)
    showList()
  }

  // ----- Prescriptions -----
  function resetRx() {
    setRx(emptyRx)
    setRxWarning('')
    setRxError('')
  }

  // confirmAllergy = true only after the doctor saw the allergy warning and chose to go ahead
  async function handlePrescribe(confirmAllergy) {
    const missing = ['medicationName', 'dosage', 'frequency', 'duration', 'pharmacy'].filter((k) => !rx[k].trim())
    if (missing.length > 0) {
      setRxError('Fill in the medication, dosage, how often, for how long and the pharmacy.')
      return
    }

    setRxSaving(true)
    setRxError('')
    setMessage('')
    try {
      await api.post(`/doctor/appointments/${selected.appointmentID}/prescriptions`, { ...rx, confirmAllergy })
      setMessage(
        `Prescribed ${rx.medicationName} ${rx.dosage}, ${rx.frequency.toLowerCase()} for ${rx.duration} `
        + `to ${selected.patientName}. Sent to ${rx.pharmacy}.`
      )
      resetRx()
      setRecord(await api.get(`/doctor/appointments/${selected.appointmentID}/record`)) // refresh the list
    } catch (e) {
      if (e.status === 409) {
        setRxWarning(e.message) // the allergy warning: ask before prescribing
      } else {
        setRxError(e.message)
      }
    } finally {
      setRxSaving(false)
    }
  }

  const visitColumns = [
    {
      key: 'appointmentDateTime',
      label: 'Time',
      format: (v) => formatDateTime(v.appointmentDateTime),
      sortValue: (v) => v.appointmentDateTime, // ISO text sorts in time order
    },
    { key: 'patientName', label: 'Patient' },
    { key: 'officeAddress', label: 'Office' },
    { key: 'appointStatus', label: 'Status' },
    {
      key: 'checkInStatus',
      label: 'Check-in',
      format: (v) => (v.appointStatus === 'Scheduled' ? v.checkInStatus ?? 'Not checked in' : '—'),
    },
    {
      key: 'vitalsRecorded',
      label: 'Vitals',
      format: (v) => (v.vitalsRecorded ? 'Recorded' : 'Waiting for nurse'),
    },
    {
      key: 'actions',
      label: 'Actions',
      hideLabel: true,
      cellClassName: 'row-actions',
      render: (v) => (
        <button type="button" onClick={() => startVisit(v)}>Open visit</button>
      ),
    },
  ]

  const formDisabled = !selected?.vitalsRecorded || loadingRecord || saving
  // Complete is only offered for a scheduled visit that has already started
  const canComplete =
    selected?.appointStatus === 'Scheduled' && hasAppointmentStarted(selected.appointmentDateTime)

  return (
    <div className="doctor-page">
      {message && <p className="success-message">{message}</p>}

      {/* ---------- List ---------- */}
      {view === 'list' && (
        <>
          <h2>My visits</h2>

          <div className="page-actions">
            <button type="button" className={range === 'today' ? 'active' : ''} onClick={() => changeRange('today')}>
              Today
            </button>
            <button type="button" className={range === 'week' ? 'active' : ''} onClick={() => changeRange('week')}>
              This week
            </button>
          </div>

          {error && <p className="error-message">{error}</p>}

          {!loaded && !error && <p>Loading visits…</p>}

          {loaded && !error && (
            <DataTable
              columns={visitColumns}
              rows={visits}
              rowKey={(v) => v.appointmentID}
              filterLabel="Filter visits"
              emptyMessage={`No visits ${range === 'today' ? 'today' : 'this week'}.`}
            />
          )}
        </>
      )}

      {/* ---------- One visit ---------- */}
      {view === 'visit' && selected && (
        <div className="panel panel-wide">
          <h2>Visit: {selected.patientName}</h2>
          <p>
            {formatDateTime(selected.appointmentDateTime)}<br />
            {selected.officeAddress} · {selected.appointStatus}
          </p>

          <h3>Vitals (recorded by the nurse)</h3>
          {!selected.vitalsRecorded && (
            <p className="field-hint">Vitals not recorded yet; the nurse records them first.</p>
          )}
          {loadingRecord && <p>Loading the record…</p>}
          {record && (
            <div className="form-grid">
              {VITALS.map((f) => (
                <div className="form-field" key={f.key}>
                  <label>{f.label}</label>
                  <p>{record[f.key]} {f.unit}</p>
                </div>
              ))}
            </div>
          )}

          {record && (
            <>
              <h3>Nursing notes</h3>
              <p className={record.nursingNotes ? '' : 'field-hint'}>
                {record.nursingNotes || 'The nurse has not written notes for this visit.'}
              </p>
            </>
          )}

          <h3>Notes</h3>
          <div className="form-grid">
            {NOTE_FIELDS.map((f) => (
              <div className="form-field" key={f.key}>
                <label htmlFor={f.key}>{f.label} ({notes[f.key].length}/{f.max})</label>
                <textarea
                  id={f.key}
                  rows={f.rows}
                  maxLength={f.max}
                  disabled={formDisabled}
                  value={notes[f.key]}
                  onChange={(e) => setNotes({ ...notes, [f.key]: e.target.value })}
                />
              </div>
            ))}
          </div>

          {selected.appointStatus === 'Scheduled' && !canComplete && (
            <p className="field-hint">This visit has not started yet, so it cannot be completed.</p>
          )}

          {error && <p className="error-message">{error}</p>}

          <div className="page-actions">
            <button type="button" className="primary-button" disabled={formDisabled} onClick={() => handleSave(false)}>
              {saving ? 'Saving…' : 'Save notes'}
            </button>
            {canComplete && (
              <button type="button" className="primary-button" disabled={formDisabled} onClick={() => handleSave(true)}>
                Save and complete
              </button>
            )}
            <button type="button" onClick={showList} disabled={saving}>Back to visits</button>
          </div>

          {/* ---------- Allergies and prescriptions ---------- */}
          {record && (
            <>
              <h3>Allergies</h3>
              {record.allergies.length === 0 ? (
                <p className="field-hint">No known allergies.</p>
              ) : (
                <div className="error-banner" role="note">
                  Allergic to:{' '}
                  {record.allergies.map((a) => `${a.allergen} (${a.severity}, ${a.reactionType})`).join('; ')}
                </div>
              )}

              <h3>Prescriptions for this visit</h3>
              {record.prescriptions.length === 0 ? (
                <p className="field-hint">None yet.</p>
              ) : (
                <ul>
                  {record.prescriptions.map((p) => (
                    <li key={p.prescriptionID}>
                      <strong>{p.medicationName}</strong> {p.dosage}, {p.frequency} for {p.duration}
                      {p.instructions ? ` · ${p.instructions}` : ''}
                      {p.pharmacy ? ` · ${p.pharmacy}` : ''}
                    </li>
                  ))}
                </ul>
              )}

              <h3>Prescribe medication</h3>
              <div className="form-grid">
                {RX_FIELDS.map((f) => (
                  <div className="form-field" key={f.key}>
                    <label htmlFor={`rx-${f.key}`}>{f.label}</label>
                    <input
                      id={`rx-${f.key}`}
                      maxLength={f.max}
                      placeholder={f.placeholder}
                      disabled={rxSaving}
                      value={rx[f.key]}
                      onChange={(e) => { setRx({ ...rx, [f.key]: e.target.value }); setRxWarning('') }}
                    />
                  </div>
                ))}
                <div className="form-field">
                  <label htmlFor="rx-pharmacy">Pharmacy</label>
                  <select
                    id="rx-pharmacy"
                    disabled={rxSaving}
                    value={rx.pharmacy}
                    onChange={(e) => setRx({ ...rx, pharmacy: e.target.value })}
                  >
                    <option value="">Choose a pharmacy</option>
                    {PHARMACIES.map((ph) => <option key={ph} value={ph}>{ph}</option>)}
                  </select>
                </div>
              </div>

              {rxError && <p className="error-message">{rxError}</p>}

              {rxWarning ? (
                <div className="error-banner" role="alert">
                  <p>{rxWarning}</p>
                  <div className="page-actions">
                    <button type="button" className="danger-link" disabled={rxSaving} onClick={() => handlePrescribe(true)}>
                      Prescribe anyway
                    </button>
                    <button type="button" disabled={rxSaving} onClick={() => setRxWarning('')}>
                      Don't prescribe
                    </button>
                  </div>
                </div>
              ) : (
                <div className="page-actions">
                  <button type="button" className="primary-button" disabled={rxSaving} onClick={() => handlePrescribe(false)}>
                    {rxSaving ? 'Saving…' : 'Prescribe'}
                  </button>
                </div>
              )}
            </>
          )}
        </div>
      )}
    </div>
  )
}
