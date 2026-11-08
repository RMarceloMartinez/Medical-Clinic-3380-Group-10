import { useEffect, useState } from 'react'
import { api } from '../../api/client'
import DataTable from '../../components/DataTable'

// Nurse page. One screen at a time:
//   'list'   = today's / this week's visits at the nurse's own office
//   'vitals' = record vitals for one visit (creates its medical record), or edit the saved ones
//   'chart'  = one patient's allergies, conditions and past visits
// The office is decided by the server from the logged-in nurse, never sent from here.

// Same limits as the CK_MedicalRecord_* constraints in the database
const VITAL_FIELDS = [
  { name: 'systolicBP', label: 'Systolic BP (mmHg)', min: 50, max: 300, step: 1 },
  { name: 'diastolicBP', label: 'Diastolic BP (mmHg)', min: 20, max: 200, step: 1 },
  { name: 'heartRate', label: 'Heart rate (bpm)', min: 20, max: 300, step: 1 },
  { name: 'temperature', label: 'Temperature (°F)', min: 56, max: 110, step: 0.1 },
  { name: 'weightPounds', label: 'Weight (lb)', min: 1, max: 1500, step: 0.1 },
  { name: 'heightInches', label: 'Height (in)', min: 1, max: 100, step: 0.1 },
]

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

// The numbers that were saved, for the success message
function describeVitals(v) {
  return `BP ${v.systolicBP}/${v.diastolicBP}, heart rate ${v.heartRate} bpm, temperature ${v.temperature} °F, weight ${v.weightPounds} lb, height ${v.heightInches} in`
}

function hasNotes(visit) {
  return Boolean(visit.clinicalNotes || visit.treatmentPlan || visit.followUp)
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
  {
    key: 'systolicBP',
    label: 'BP',
    format: (r) => (r.systolicBP != null ? `${r.systolicBP}/${r.diastolicBP}` : ''),
    sortValue: (r) => r.systolicBP,
  },
  { key: 'heartRate', label: 'Heart rate', align: 'right' },
  { key: 'weightPounds', label: 'Weight (lb)', align: 'right' },
]

export default function NurseVisits() {
  const [view, setView] = useState('list')
  const [range, setRange] = useState('today') // 'today' | 'week'
  const [visits, setVisits] = useState([])
  const [loaded, setLoaded] = useState(false)
  const [error, setError] = useState('')
  const [message, setMessage] = useState('')
  const [selected, setSelected] = useState(null) // the visit being worked on
  const [vitals, setVitals] = useState({})
  const [saving, setSaving] = useState(false)
  const [loadingVitals, setLoadingVitals] = useState(false)
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

  function showList() {
    setError('')
    setSelected(null)
    setChart(null)
    setVitals({})
    setView('list')
  }

  // ----- Record / edit vitals -----
  // A visit that already has vitals opens in edit mode with the saved numbers filled in
  async function startVitals(visit) {
    setMessage('')
    setError('')
    setSelected(visit)
    setVitals({})
    setView('vitals')

    if (!visit.vitalsRecorded) return

    setLoadingVitals(true)
    try {
      const saved = await api.get(`/nurse/appointments/${visit.appointmentID}/vitals`)
      setVitals(Object.fromEntries(VITAL_FIELDS.map((f) => [f.name, String(saved[f.name])])))
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
    setSaving(true)
    setError('')
    try {
      const body = Object.fromEntries(VITAL_FIELDS.map((f) => [f.name, Number(vitals[f.name])]))
      if (selected.vitalsRecorded) {
        await api.put(`/nurse/appointments/${selected.appointmentID}/vitals`, body)
        setMessage(`Updated vitals for ${selected.patientName}, ${formatWhen(selected.appointmentDateTime)}: ${describeVitals(body)}.`)
      } else {
        await api.post(`/nurse/appointments/${selected.appointmentID}/vitals`, body)
        setMessage(`Recorded vitals for ${selected.patientName}, ${formatWhen(selected.appointmentDateTime)}: ${describeVitals(body)}.`)
      }
      showList()
      await loadVisits()
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

  const visitColumns = [
    {
      key: 'appointmentDateTime',
      label: 'Time',
      format: (v) => formatDateTime(v.appointmentDateTime),
      sortValue: (v) => v.appointmentDateTime, // ISO text sorts in time order
    },
    { key: 'patientName', label: 'Patient' },
    { key: 'doctorName', label: 'Doctor' },
    {
      key: 'vitalsRecorded',
      label: 'Vitals',
      format: (v) => (v.vitalsRecorded ? 'Recorded' : 'Not recorded'),
    },
    {
      key: 'actions',
      label: 'Actions',
      hideLabel: true,
      cellClassName: 'row-actions',
      render: (v) => (
        <>
          <button type="button" onClick={() => startVitals(v)}>
            {v.vitalsRecorded ? 'Edit vitals' : 'Record vitals'}
          </button>
          <button type="button" onClick={() => startChart(v)}>View chart</button>
        </>
      ),
    },
  ]

  return (
    <div className="nurse-page">
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

          {message && <p className="success-message">{message}</p>}
          {error && <p className="error-message">{error}</p>}

          {!loaded && !error && <p>Loading visits…</p>}

          {loaded && !error && (
            <DataTable
              columns={visitColumns}
              rows={visits}
              rowKey={(v) => v.appointmentID}
              filterLabel="Filter visits"
              emptyMessage={`No scheduled visits at your office ${range === 'today' ? 'today' : 'this week'}.`}
            />
          )}
        </>
      )}

      {/* ---------- Record vitals ---------- */}
      {view === 'vitals' && selected && (
        <div className="panel panel-wide">
          <h2>{selected.vitalsRecorded ? 'Edit vitals' : 'Record vitals'}</h2>
          <p>
            <strong>{selected.patientName}</strong> with {selected.doctorName}<br />
            {formatDateTime(selected.appointmentDateTime)}
          </p>

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
                  disabled={loadingVitals}
                  onChange={(e) => setVitals({ ...vitals, [f.name]: e.target.value })}
                />
              </div>
            ))}
          </div>

          <p className="field-hint">
            {selected.vitalsRecorded
              ? 'Saving replaces the vitals on file for this visit. They can be changed until the doctor completes the visit.'
              : 'Check the numbers before saving. You can edit them later, until the doctor completes the visit.'}
          </p>

          {error && <p className="error-message">{error}</p>}

          <div className="page-actions">
            <button type="button" className="primary-button" onClick={handleSaveVitals} disabled={saving || loadingVitals}>
              {saving ? 'Saving…' : selected.vitalsRecorded ? 'Save changes' : 'Save vitals'}
            </button>
            <button type="button" onClick={showList} disabled={saving}>Back to visits</button>
          </div>
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

              <h3>Conditions</h3>
              <DataTable
                columns={conditionColumns}
                rows={chart.conditions}
                rowKey={(r) => r.conditionID}
                filterLabel="Filter conditions"
                emptyMessage="No conditions on record."
              />

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
