import { useEffect, useState } from 'react'
import { api } from '../../api/client'
import DataTable from '../../components/DataTable'

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

  // ----- Record vitals -----
  function startVitals(visit) {
    setMessage('')
    setError('')
    setSelected(visit)
    setVitals({})
    setView('vitals')
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
      await api.post(`/nurse/appointments/${selected.appointmentID}/vitals`, body)
      setMessage(`Vitals saved for ${selected.patientName}.`)
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
          <button type="button" disabled={v.vitalsRecorded} onClick={() => startVitals(v)}>
            Record vitals
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
              emptyMessage={`No scheduled visits ${range === 'today' ? 'today' : 'in the next 7 days'}.`}
            />
          )}
        </>
      )}

      {/* ---------- Record vitals ---------- */}
      {view === 'vitals' && selected && (
        <div className="panel panel-wide">
          <h2>Record vitals</h2>
          <p>
            <strong>{selected.patientName}</strong> with {selected.doctorName}<br />
            {formatDateTime(selected.appointmentDateTime)}
          </p>

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
                  onChange={(e) => setVitals({ ...vitals, [f.name]: e.target.value })}
                />
              </div>
            ))}
          </div>

          <p className="field-hint">
            Vitals can be recorded only once per visit, so check the numbers before saving.
          </p>

          {error && <p className="error-message">{error}</p>}

          <div className="page-actions">
            <button type="button" className="primary-button" onClick={handleSaveVitals} disabled={saving}>
              {saving ? 'Saving…' : 'Save vitals'}
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
