import { useEffect, useState } from 'react'
import { api } from '../../api/client'
import DataTable from '../../components/DataTable'

// Nurse page. One screen at a time:
//   'list'  = today's / this week's visits at the nurse's own office, with a status for each
//   'visit' = one visit: check-in buttons, and two tabs (Vitals, Nursing notes)
//   'chart' = one patient's allergies, medications, conditions, vital history and past visits
// The office is decided by the server from the logged-in nurse, never sent from here.

// Same limits as the CK_MedicalRecord_* constraints in the database
const VITAL_FIELDS = [
  { name: 'systolicBP', label: 'Systolic BP (mmHg)', short: 'systolic BP', unit: 'mmHg', min: 50, max: 300, step: 1 },
  { name: 'diastolicBP', label: 'Diastolic BP (mmHg)', short: 'diastolic BP', unit: 'mmHg', min: 20, max: 200, step: 1 },
  { name: 'heartRate', label: 'Heart rate (bpm)', short: 'heart rate', unit: 'bpm', min: 20, max: 300, step: 1 },
  { name: 'temperature', label: 'Temperature (°F)', short: 'temperature', unit: '°F', min: 56, max: 110, step: 0.1 },
  { name: 'weightPounds', label: 'Weight (lb)', short: 'weight', unit: 'lb', min: 1, max: 1500, step: 0.1 },
  { name: 'heightInches', label: 'Height (in)', short: 'height', unit: 'in', min: 1, max: 100, step: 0.1 },
]

const CHECK_IN_STATUSES = ['Checked in', 'Waiting', 'Ready for doctor']

function formatDate(value) {
  return new Date(value).toLocaleDateString([], { weekday: 'short', month: 'short', day: 'numeric', year: 'numeric' })
}

function formatTime(value) {
  return new Date(value).toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' })
}

function formatDateTime(value) {
  return `${formatDate(value)}, ${formatTime(value)}`
}

function formatShortDate(value) {
  return value ? new Date(value).toLocaleDateString() : ''
}

// "Nov 11 at 10:00 AM", used in the success messages
function formatWhen(value) {
  const day = new Date(value).toLocaleDateString([], { month: 'short', day: 'numeric' })
  return `${day} at ${formatTime(value)}`
}

// All the numbers that were saved, for the "recorded" message
function describeVitals(v) {
  return `BP ${v.systolicBP}/${v.diastolicBP}, heart rate ${v.heartRate} bpm, temperature ${v.temperature} °F, weight ${v.weightPounds} lb, height ${v.heightInches} in`
}

// Only the numbers that changed, for the "updated" message, e.g. "heart rate 72 → 75 bpm"
function describeChanges(before, after) {
  return VITAL_FIELDS
    .filter((f) => Number(before[f.name]) !== Number(after[f.name]))
    .map((f) => `${f.short} ${before[f.name]} → ${after[f.name]} ${f.unit}`)
}

// Returns the first problem with the entered vitals, or '' if they look fine
function checkVitals(values) {
  for (const f of VITAL_FIELDS) {
    const raw = values[f.name]
    const n = Number(raw)
    if (raw === undefined || raw === '' || Number.isNaN(n) || n < f.min || n > f.max) {
      return `${f.label}: enter a number from ${f.min} to ${f.max}.`
    }
  }
  if (Number(values.systolicBP) <= Number(values.diastolicBP)) {
    return 'Systolic pressure must be higher than diastolic.'
  }
  return ''
}

function hasNotes(visit) {
  return Boolean(visit.clinicalNotes || visit.treatmentPlan || visit.followUp)
}

const allergyColumns = [
  { key: 'allergen', label: 'Allergen' },
  { key: 'reactionType', label: 'Reaction' },
  { key: 'severity', label: 'Severity' },
  {
    key: 'dateIdentified',
    label: 'Identified',
    format: (r) => formatShortDate(r.dateIdentified),
    sortValue: (r) => r.dateIdentified,
  },
]

// Pharmacy is not shown yet: it needs to be added to the API and to this list
const medicationColumns = [
  { key: 'medicationName', label: 'Medication' },
  { key: 'dosage', label: 'Dose' },
  { key: 'frequency', label: 'Frequency' },
  { key: 'duration', label: 'Duration' },
  { key: 'instructions', label: 'Instructions' },
  {
    key: 'prescribedOn',
    label: 'Prescribed',
    format: (r) => formatShortDate(r.prescribedOn),
    sortValue: (r) => r.prescribedOn,
  },
  { key: 'doctorName', label: 'Doctor' },
]

const conditionColumns = [
  { key: 'conditionName', label: 'Condition' },
  { key: 'conditionType', label: 'Type' },
  { key: 'severity', label: 'Severity' },
  { key: 'isHereditary', label: 'Hereditary', format: (r) => (r.isHereditary ? 'Yes' : 'No') },
  {
    key: 'dateDiagnosed',
    label: 'Diagnosed',
    format: (r) => formatShortDate(r.dateDiagnosed),
    sortValue: (r) => r.dateDiagnosed,
  },
]

const pastVisitColumns = [
  {
    key: 'appointmentDateTime',
    label: 'Date',
    format: (r) => formatShortDate(r.appointmentDateTime),
    sortValue: (r) => r.appointmentDateTime,
  },
  { key: 'doctorName', label: 'Doctor' },
  { key: 'office', label: 'Office' },
]

// Past visits' vitals side by side: one column per visit (oldest to newest), one row per vital.
// Shows the last 6 visits that have vitals.
function VitalHistory({ pastVisits }) {
  const visits = [...pastVisits].filter((p) => p.systolicBP != null).reverse().slice(-6)

  if (visits.length === 0) {
    return <p>No vitals on record yet.</p>
  }

  const rows = [
    { label: 'Blood pressure (mmHg)', show: (p) => `${p.systolicBP}/${p.diastolicBP}` },
    { label: 'Heart rate (bpm)', show: (p) => p.heartRate },
    { label: 'Temperature (°F)', show: (p) => p.temperature },
    { label: 'Weight (lb)', show: (p) => p.weightPounds },
  ]

  return (
    <div className="dt-wrap">
      <table className="data-table">
        <thead>
          <tr>
            <th scope="col">Vital</th>
            {visits.map((p) => (
              <th key={p.appointmentID} scope="col">{formatShortDate(p.appointmentDateTime)}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={row.label}>
              <th scope="row">{row.label}</th>
              {visits.map((p) => (
                <td key={p.appointmentID}>{row.show(p) ?? ''}</td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}

export default function NurseVisits() {
  const [view, setView] = useState('list')
  const [range, setRange] = useState('today') // 'today' | 'week'
  const [visits, setVisits] = useState([])
  const [loaded, setLoaded] = useState(false)
  const [error, setError] = useState('')
  const [message, setMessage] = useState('')
  const [selected, setSelected] = useState(null) // the visit that is open
  const [tab, setTab] = useState('vitals')       // 'vitals' | 'notes'
  const [vitals, setVitals] = useState({})       // what is typed in the form (as text)
  const [savedVitals, setSavedVitals] = useState(null) // the numbers on file, to say what changed
  const [nursingNotes, setNursingNotes] = useState('')
  const [savedNotes, setSavedNotes] = useState('')     // the notes on file, to spot "no change"
  const [loadingVitals, setLoadingVitals] = useState(false)
  const [saving, setSaving] = useState(false)
  const [chart, setChart] = useState(null)

  // First load
  useEffect(() => {
    loadVisits('today')
  }, [])

  async function loadVisits(currentRange = range) {
    setError('')
    try {
      setVisits(await api.get(`/nurse/visits?range=${currentRange}`))
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

  // Back to the list. It reloads, so statuses and check-in changes show up.
  function showList() {
    setError('')
    setSelected(null)
    setChart(null)
    setView('list')
    loadVisits()
  }

  // A completed visit ("Seen") can no longer be changed by the nurse
  const readOnly = selected?.visitStatus === 'Seen'

  // ----- Open a visit (record / edit vitals, nursing notes, check-in) -----
  async function startVisit(visit) {
    setMessage('')
    setError('')
    setSelected(visit)
    setTab('vitals')
    setVitals({})
    setSavedVitals(null)
    setNursingNotes('')
    setSavedNotes('')
    setView('visit')

    // No vitals yet: nothing is saved, so the form starts empty
    if (!visit.vitalsRecorded) return

    setLoadingVitals(true)
    try {
      const saved = await api.get(`/nurse/appointments/${visit.appointmentID}/vitals`)
      setVitals(Object.fromEntries(VITAL_FIELDS.map((f) => [f.name, String(saved[f.name])])))
      setSavedVitals(Object.fromEntries(VITAL_FIELDS.map((f) => [f.name, Number(saved[f.name])])))
      setNursingNotes(saved.nursingNotes ?? '')
      setSavedNotes((saved.nursingNotes ?? '').trim())
    } catch (e) {
      setError(e.message)
    } finally {
      setLoadingVitals(false)
    }
  }

  async function handleSaveVitals() {
    const problem = checkVitals(vitals)
    if (problem) {
      setError(problem)
      return
    }

    const body = Object.fromEntries(VITAL_FIELDS.map((f) => [f.name, Number(vitals[f.name])]))
    const when = formatWhen(selected.appointmentDateTime)

    if (selected.vitalsRecorded) {
      // Editing: say exactly which numbers changed, and skip the request if none did
      const changes = describeChanges(savedVitals, body)
      if (changes.length === 0) {
        setError('Nothing to save: these are the same vitals already on file.')
        return
      }
      setSaving(true)
      setError('')
      setMessage('')
      try {
        await api.put(`/nurse/appointments/${selected.appointmentID}/vitals`, body)
        setSavedVitals(body)
        setMessage(`Updated vitals for ${selected.patientName}, ${when}: ${changes.join('; ')}.`)
      } catch (e) {
        setError(e.message)
      } finally {
        setSaving(false)
      }
      return
    }

    // First time: this creates the visit's medical record
    setSaving(true)
    setError('')
    setMessage('')
    try {
      await api.post(`/nurse/appointments/${selected.appointmentID}/vitals`, body)
      setSavedVitals(body)
      setSelected({ ...selected, vitalsRecorded: true, visitStatus: 'Waiting for doctor' })
      setMessage(`Recorded vitals for ${selected.patientName}, ${when}: ${describeVitals(body)}.`)
    } catch (e) {
      setError(e.message)
    } finally {
      setSaving(false)
    }
  }

  async function handleSaveNotes() {
    if (nursingNotes.trim() === savedNotes) {
      setError('Nothing to save: the nursing notes have not changed.')
      return
    }
    setSaving(true)
    setError('')
    setMessage('')
    try {
      await api.put(`/nurse/appointments/${selected.appointmentID}/nursing-notes`, { nursingNotes })
      const cleared = nursingNotes.trim() === ''
      setSavedNotes(nursingNotes.trim())
      const when = formatWhen(selected.appointmentDateTime)
      setMessage(
        cleared
          ? `Cleared the nursing notes for ${selected.patientName}, ${when}.`
          : `Saved nursing notes for ${selected.patientName}, ${when}.`
      )
    } catch (e) {
      setError(e.message)
    } finally {
      setSaving(false)
    }
  }

  async function handleCheckIn(status) {
    if (status === selected.checkInStatus) return
    setSaving(true)
    setError('')
    setMessage('')
    try {
      await api.put(`/nurse/appointments/${selected.appointmentID}/check-in`, { checkInStatus: status })
      setSelected({ ...selected, checkInStatus: status })
      setMessage(`Set ${selected.patientName}'s check-in status to "${status}" (${formatWhen(selected.appointmentDateTime)}).`)
    } catch (e) {
      setError(e.message)
    } finally {
      setSaving(false)
    }
  }

  // ----- Patient chart -----
  async function startChart(visit) {
    setMessage('')
    setError('')
    setSelected(visit)
    setChart(null)
    setView('chart')
    try {
      setChart(await api.get(`/nurse/patients/${visit.patientID}/chart`))
    } catch (e) {
      setError(e.message)
    }
  }

  function vitalsButtonLabel(v) {
    if (v.visitStatus === 'Seen') return 'View vitals'
    return v.vitalsRecorded ? 'Edit vitals' : 'Record vitals'
  }

  const visitColumns = [
    {
      key: 'appointmentDateTime',
      label: 'Time',
      format: (v) => formatDateTime(v.appointmentDateTime),
      sortValue: (v) => v.appointmentDateTime, // ISO text sorts in time order
    },
    { key: 'patientName', label: 'Patient' },
    { key: 'doctorName', label: 'Doctor' },
    { key: 'visitStatus', label: 'Status' },
    { key: 'checkInStatus', label: 'Check-in', format: (v) => v.checkInStatus ?? 'Not checked in' },
    {
      key: 'actions',
      label: 'Actions',
      hideLabel: true,
      cellClassName: 'row-actions',
      render: (v) => (
        <>
          <button type="button" onClick={() => startVisit(v)}>{vitalsButtonLabel(v)}</button>
          <button type="button" onClick={() => startChart(v)}>View chart</button>
        </>
      ),
    },
  ]

  return (
    <div className="nurse-page">
      {message && <p className="success-message">{message}</p>}

      {/* ---------- List ---------- */}
      {view === 'list' && (
        <>
          <h2>Visits at your office</h2>

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
              emptyMessage={`No visits at your office ${range === 'today' ? 'today' : 'this week'}.`}
            />
          )}
        </>
      )}

      {/* ---------- One visit: check-in + Vitals / Nursing notes tabs ---------- */}
      {view === 'visit' && selected && (
        <div className="panel panel-wide">
          <h2>{selected.patientName}</h2>
          <p>
            {formatDateTime(selected.appointmentDateTime)} with {selected.doctorName}<br />
            Status: {selected.visitStatus}
          </p>

          <h3>Check-in</h3>
          <div className="page-actions" role="group" aria-label="Check-in status">
            {CHECK_IN_STATUSES.map((s) => (
              <button
                key={s}
                type="button"
                className={selected.checkInStatus === s ? 'active' : ''}
                aria-pressed={selected.checkInStatus === s}
                disabled={readOnly || saving}
                onClick={() => handleCheckIn(s)}
              >
                {s}
              </button>
            ))}
          </div>
          {!selected.checkInStatus && <p className="field-hint">Not checked in yet.</p>}

          <div className="page-actions" role="group" aria-label="Visit sections">
            <button
              type="button"
              className={tab === 'vitals' ? 'active' : ''}
              aria-pressed={tab === 'vitals'}
              onClick={() => { setTab('vitals'); setError('') }}
            >
              {readOnly ? 'Vitals' : selected.vitalsRecorded ? 'Edit vitals' : 'Record vitals'}
            </button>
            <button
              type="button"
              className={tab === 'notes' ? 'active' : ''}
              aria-pressed={tab === 'notes'}
              onClick={() => { setTab('notes'); setError('') }}
            >
              Nursing notes
            </button>
          </div>

          {/* Vitals tab */}
          {tab === 'vitals' && (
            <>
              {loadingVitals && <p>Loading saved vitals…</p>}

              <div className="form-grid">
                {VITAL_FIELDS.map((f) => (
                  <div className="form-field" key={f.name}>
                    <label htmlFor={f.name}>{f.label}</label>
                    <input
                      id={f.name}
                      type="number"
                      step={f.step}
                      min={f.min}
                      max={f.max}
                      value={vitals[f.name] ?? ''}
                      disabled={readOnly || loadingVitals}
                      onChange={(e) => setVitals({ ...vitals, [f.name]: e.target.value })}
                    />
                  </div>
                ))}
              </div>

              <p className="field-hint">
                {readOnly
                  ? 'This visit is completed, so the vitals can no longer be changed.'
                  : selected.vitalsRecorded
                    ? 'Saving replaces the vitals on file. They can be changed until the doctor completes the visit.'
                    : 'Check the numbers before saving. You can edit them later, until the doctor completes the visit.'}
              </p>

              {error && <p className="error-message">{error}</p>}

              <div className="page-actions">
                {!readOnly && (
                  <button type="button" className="primary-button" onClick={handleSaveVitals} disabled={saving || loadingVitals}>
                    {saving ? 'Saving…' : selected.vitalsRecorded ? 'Save changes' : 'Save vitals'}
                  </button>
                )}
                <button type="button" onClick={showList} disabled={saving}>Back to visits</button>
              </div>
            </>
          )}

          {/* Nursing notes tab */}
          {tab === 'notes' && (
            <>
              {!selected.vitalsRecorded ? (
                <p className="field-hint">
                  Record the vitals first. Nursing notes are saved on the visit's record, which is created when the vitals are saved.
                </p>
              ) : (
                <div className="form-field">
                  <label htmlFor="nursingNotes">
                    Symptoms, complaints and observations ({nursingNotes.length}/500)
                  </label>
                  <textarea
                    id="nursingNotes"
                    rows={6}
                    maxLength={500}
                    value={nursingNotes}
                    disabled={readOnly || loadingVitals || saving}
                    onChange={(e) => setNursingNotes(e.target.value)}
                  />
                </div>
              )}

              {readOnly && (
                <p className="field-hint">This visit is completed, so the nursing notes can no longer be changed.</p>
              )}

              {error && <p className="error-message">{error}</p>}

              <div className="page-actions">
                {!readOnly && selected.vitalsRecorded && (
                  <button type="button" className="primary-button" onClick={handleSaveNotes} disabled={saving || loadingVitals}>
                    {saving ? 'Saving…' : 'Save nursing notes'}
                  </button>
                )}
                <button type="button" onClick={showList} disabled={saving}>Back to visits</button>
              </div>
            </>
          )}
        </div>
      )}

      {/* ---------- Patient chart ---------- */}
      {view === 'chart' && selected && (
        <div className="panel panel-wide">
          <h2>Chart: {selected.patientName}</h2>

          {error && <p className="error-message">{error}</p>}
          {!chart && !error && <p>Loading chart…</p>}

          {chart && (
            <>
              <h3>Allergies</h3>
              <DataTable
                columns={allergyColumns}
                rows={chart.allergies}
                rowKey={(r) => r.allergyID}
                filterLabel="Filter allergies"
                emptyMessage="No allergies on record."
              />

              <h3>Medications</h3>
              <DataTable
                columns={medicationColumns}
                rows={chart.medications}
                rowKey={(r) => `${r.recordID}-${r.prescriptionID}`}
                filterLabel="Filter medications"
                emptyMessage="No medications on record."
              />

              <h3>Conditions</h3>
              <DataTable
                columns={conditionColumns}
                rows={chart.conditions}
                rowKey={(r) => r.conditionID}
                filterLabel="Filter conditions"
                emptyMessage="No conditions on record."
              />

              <h3>Vital history</h3>
              <VitalHistory pastVisits={chart.pastVisits} />

              <h3>Past visits</h3>
              <DataTable
                columns={pastVisitColumns}
                rows={chart.pastVisits}
                rowKey={(r) => r.appointmentID}
                filterLabel="Filter past visits"
                emptyMessage="No completed visits yet."
              />

              {chart.pastVisits.some(hasNotes) && (
                <>
                  <h3>Notes from past visits</h3>
                  {chart.pastVisits.filter(hasNotes).map((p) => (
                    <div key={p.appointmentID}>
                      <p>
                        <strong>{formatShortDate(p.appointmentDateTime)}</strong> with {p.doctorName}
                      </p>
                      {p.clinicalNotes && <p>Clinical notes: {p.clinicalNotes}</p>}
                      {p.treatmentPlan && <p>Treatment plan: {p.treatmentPlan}</p>}
                      {p.followUp && <p>Follow-up: {p.followUp}</p>}
                    </div>
                  ))}
                </>
              )}
            </>
          )}

          <div className="page-actions">
            <button type="button" onClick={showList}>Back to visits</button>
          </div>
        </div>
      )}
    </div>
  )
}
