import { useEffect, useState } from 'react'
import { api } from '../../api/client'

// Patient management (moved out of App.jsx). One screen at a time:
//   list -> add | edit | remove -> back to list
const emptyPatient = {
  ssn: '', firstName: '', middleName: '', lastName: '',
  streetAddress: '', apartmentNum: '', city: '', state: '', zipCode: '', country: '',
  phone: '', sex: '', dateOfBirth: '', email: '', primaryDoctorID: '',
}

function patientLabel(p) {
  return `${p.firstName} ${p.lastName} (born ${p.dateOfBirth})`
}

function validate(form, isNew) {
  const errors = {}

  const required = {
    firstName: 'Please enter a first name.',
    lastName: 'Please enter a last name.',
    streetAddress: 'Please enter a street address.',
    city: 'Please enter a city.',
    state: 'Please enter a state.',
    zipCode: 'Please enter a ZIP code.',
    country: 'Please enter a country.',
    phone: 'Please enter a phone number.',
    sex: 'Please select a sex.',
    dateOfBirth: 'Please enter a date of birth.',
    email: 'Please enter an email address.',
  }

  Object.entries(required).forEach(([field, message]) => {
    if (!String(form[field] ?? '').trim()) {
      errors[field] = message
    }
  })
  if (form.dateOfBirth) {
    const dob = new Date(`${form.dateOfBirth}T00:00:00`)
    const today = new Date()
    today.setHours(0, 0, 0, 0)

    if (Number.isNaN(dob.getTime())) {
      errors.dateOfBirth = 'Please enter a valid date of birth.'
    } else if (dob > today) {
      errors.dateOfBirth = 'Date of birth cannot be in the future.'
    }
  }
  if (form.phone) {
    const digits = form.phone.replace(/\D/g, '')
    if (digits.length !== 10) {
      errors.phone = 'Please enter a valid 10-digit phone number.'
    }
  }

  
  if (form.email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email)) {
    errors.email = 'Please enter a valid email address.'
  }

  if (isNew && !form.primaryDoctorID) {
    errors.primaryDoctorID = 'Please select a primary doctor.'
  }

  if (isNew && form.ssn && !/^\d{3}-\d{2}-\d{4}$/.test(form.ssn)) {
    errors.ssn = 'Use the format 123-45-6789.'
  }

  return errors
}

function toRequestBody(form, isNew) {
  const body = {
    firstName: form.firstName,
    middleName: form.middleName || null,
    lastName: form.lastName,
    streetAddress: form.streetAddress,
    apartmentNum: form.apartmentNum || null,
    city: form.city,
    state: form.state,
    zipCode: form.zipCode,
    country: form.country,
    phone: form.phone,
    sex: form.sex,
    dateOfBirth: form.dateOfBirth,
    email: form.email,
  }
  if (isNew) {
    body.ssn = form.ssn.trim() || null          // optional; set once, when the patient is created
    body.primaryDoctorID = Number(form.primaryDoctorID)
  }
  return body
}

export default function Patients() {
  const [view, setView] = useState('list')       // 'list' | 'add' | 'edit' | 'remove'
  const [patients, setPatients] = useState([])
  const [form, setForm] = useState(emptyPatient)
  const [errors, setErrors] = useState({})
  const [selectedId, setSelectedId] = useState('')
  const [selected, setSelected] = useState(null)  // the patient loaded for edit / remove
  const [message, setMessage] = useState('')
  const [error, setError] = useState('')
  const [doctors, setDoctors] = useState([]);
  const [searchTerm, setSearchTerm] = useState('')

  async function loadPatients() {
    try {
      setPatients(await api.get('/patients'))
    } catch (e) {
      setError(`Could not load patients: ${e.message}`)
    }
  }

  useEffect(() => {
    api.get('/patients')
      .then(setPatients)
      .catch((e) => setError(`Could not load patients: ${e.message}`))
      api.get('/lookups/primary-doctors')
        .then(setDoctors)
        .catch((e) => setError(`Could not load doctors: ${e.message}`))
  }, [])

  function open(nextView) {
    setForm(emptyPatient)
    setErrors({})
    setSelectedId('')
    setSelected(null)
    setError('')
    if (nextView !== 'list') setMessage('')
    setView(nextView)
  }

  function update(field, value) {
    setForm({ ...form, [field]: value })
  }

  async function finish(text) {
    await loadPatients()
    open('list')
    setMessage(text)
  }

  // ----- Add -----
  async function handleAdd() {
  const found = validate(form, true)
  setErrors(found)
  setError('')

  if (Object.keys(found).length > 0) return

  try {
    const result = await api.post('/patients', toRequestBody(form, true))

    const patientId =
      result?.patientID ?? result?.patientId ?? result?.id

    const doctor = doctors.find(
      (d) => String(d.id) === String(form.primaryDoctorID)
    )

    const doctorName = doctor?.name || 'the selected doctor'

    await finish(
      `Added ${form.firstName} ${form.lastName} (patient ID ${patientId}). They can now book with ${doctorName}.`
    )
  } catch (e) {
    setError(e.message || 'Could not save patient.')
  }
}

  // ----- Edit -----
  async function loadForEdit(id) {
    setSelectedId(id)
    setSelected(null)
    setError('')
    if (id === '') return
    try {
      const p = await api.get(`/patients/${id}`)
      setSelected(p)
      setForm({
        ...emptyPatient,
        firstName: p.firstName ?? '',
        middleName: p.middleName ?? '',
        lastName: p.lastName ?? '',
        streetAddress: p.streetAddress ?? '',
        apartmentNum: p.apartmentNum ?? '',
        city: p.city ?? '',
        state: p.state ?? '',
        zipCode: p.zipCode ?? '',
        country: p.country ?? '',
        phone: p.phone ?? '',
        sex: p.sex ?? '',
        dateOfBirth: p.dateOfBirth ? p.dateOfBirth.slice(0, 10) : '',
        email: p.email ?? '',
      })
    } catch (e) {
      setError(`Could not load patient: ${e.message}`)
    }
  }

  async function handleUpdate() {
    const found = validate(form, false)
    setErrors(found)
    setError('')
    if (Object.keys(found).length > 0) return

    try {
      await api.put(`/patients/${selectedId}`, toRequestBody(form, false))
      await finish(`Saved changes to ${form.firstName} ${form.lastName}.`)
    } catch (e) {
      setError(e.message || 'Could not update patient.')
    }
  }

  // ----- Remove -----
  async function loadForRemove(id) {
    setSelectedId(id)
    setSelected(null)
    setError('')
    if (id === '') return
    try {
      setSelected(await api.get(`/patients/${id}`))
    } catch (e) {
      setError(`Could not find patient: ${e.message}`)
    }
  }

  async function handleRemove() {
  if (!selected) return

  const patientName = `${selected.firstName} ${selected.lastName}`

  if (
    !window.confirm(
      `Delete ${patientName}? Their past visits stay in the records.`
    )
  ) {
    return
  }

  try {
    await api.delete(`/patients/${selectedId}`)
    await finish(`${patientName} was removed.`)
  } catch (e) {
    setError(e.message || 'Could not remove patient.')
  }
}

  // One label + input + error message
  function field(name, label, props = {}) {
    return (
      <>
        <label htmlFor={name}>{label}</label>
        <input id={name} value={form[name]} onChange={(e) => update(name, e.target.value)} {...props} />
        {errors[name] && <p className="field-error">{errors[name]}</p>}
      </>
    )
  }

  function patientFields(isNew) {
    return (
      <>
        {field('firstName', 'First name', { maxLength: 15 })}
        {field('middleName', 'Middle name (optional)', { maxLength: 15 })}
        {field('lastName', 'Last name', { maxLength: 31 })}
        {field('dateOfBirth', 'Date of birth', { type: 'date' })}
        <label htmlFor="sex">Sex</label>
        <select id="sex" value={form.sex} onChange={(e) => update('sex', e.target.value)}>
          <option value="">Select sex</option>
          <option value="M">M</option>
          <option value="F">F</option>
          <option value="I">I</option>
        </select>
        {errors.sex && <p className="field-error">{errors.sex}</p>}
        {isNew && field('ssn', 'SSN (optional)', { placeholder: '123-45-6789', maxLength: 11 })}
        {isNew && (
          <>
            <label htmlFor="primaryDoctorID">Primary care doctor</label>
            <select id="primaryDoctorID" value={form.primaryDoctorID}
              onChange={(e) => update('primaryDoctorID', e.target.value)}>
              <option value="">Select a doctor</option>
              {doctors.map((d) => (
                <option key={d.id} value={d.id}>{d.name}</option>
              ))}
            </select>
            {errors.primaryDoctorID && <p className="field-error">{errors.primaryDoctorID}</p>}
          </>
        )}
        {field('phone', 'Phone number', { type: 'tel', maxLength: 10 })}
        {field('email', 'Email', { type: 'email', maxLength: 100 })}
        {field('streetAddress', 'Street address', { maxLength: 80 })}
        {field('apartmentNum', 'Apartment number (optional)', { maxLength: 5 })}
        {field('city', 'City', { maxLength: 48 })}
        {field('state', 'State', { maxLength: 20 })}
        {field('zipCode', 'ZIP code', { maxLength: 5 })}
        {field('country', 'Country', { maxLength: 56 })}
      </>
    )
  }

  function patientPicker(onPick) {
    return (
      <>
        <label htmlFor="patientPick">Patient</label>
        <select id="patientPick" value={selectedId} onChange={(e) => onPick(e.target.value)}>
          <option value="">Select a patient</option>
          {patients.map((p) => (
            <option key={p.patientID} value={p.patientID}>{patientLabel(p)}</option>
          ))}
        </select>
      </>
    )
  }
    const filteredPatients = patients.filter((p) => {
  const fullName = `${p.firstName} ${p.lastName}`.toLowerCase()
  return fullName.includes(searchTerm.toLowerCase().trim())
})
  return (
    <div className="patients-page">
      <h2>Patient Management</h2>

      {view === 'list' && (
        <>
          <div className="page-actions">
            <button type="button" onClick={() => open('add')}>Add patient</button>
            <button type="button" onClick={() => open('edit')}>Edit patient</button>
            <button type="button" onClick={() => open('remove')}>Remove patient</button>
          </div>
          <div className="patient-search">
            <label htmlFor="patientSearch">Search patients</label>
              <input
                id="patientSearch"
                type="text"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder="Search by first or last name"
              />
          </div>
          {message && <p className="success-message">{message}</p>}
          {error && <p className="error-message">{error}</p>}

          <table className="data-table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Date of birth</th>
                <th>Phone</th>
                <th>Email</th>
              </tr>
            </thead>
            <tbody>
              {filteredPatients.length === 0 ? (
            <tr>
              <td colSpan="4">
                {searchTerm.trim()? `No patients match '${searchTerm}'.`: 'No patients found.'}
              </td>
            </tr>
                  ) : (
                  filteredPatients.map((p) => ( 
                  <tr key={p.patientID}>
                    <td>{p.firstName} {p.lastName}</td>
                    <td>{p.dateOfBirth}</td>
                    <td>{p.phone}</td>
                    <td>{p.email}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </>
      )}

      {view === 'add' && (
        <div className="add-Patient">
          <h2>Add New Patient</h2>

       {error && <div className="error-banner" role="alert">{error}</div>}

       {patientFields(true)}
       <button type="button" onClick={handleAdd}>Save</button>
       <button type="button" className="back-button" onClick={() => open('list')}>
        Back to patients
       </button>
        </div>
)}

      {view === 'edit' && (
        <div className="edit-Patient">
          <h2>Edit Patient</h2>
          {error && <div className="error-banner" role="alert">{error}</div>}
          {patientPicker(loadForEdit)}
          {selected && (
            <>
              <h3>Patient information</h3>
              {patientFields(false)}
              <button type="button" onClick={handleUpdate}>Save changes</button>
            </>
          )}
          <button type="button" className="back-button" onClick={() => open('list')}>Back to patients</button>
        </div>
      )}

      {view === 'remove' && (
        <div className="remove-patient">
          <h2>Remove Patient</h2>
          {patientPicker(loadForRemove)}
          {selected && (
            <div className="patient-summary">
              <p><strong>Name:</strong> {selected.firstName} {selected.lastName}</p>
              <p><strong>Born:</strong> {selected.dateOfBirth}</p>
              <p><strong>Phone:</strong> {selected.phone}</p>
              <p><strong>Email:</strong> {selected.email}</p>
            </div>
          )}
          {error && <p className="error-message">{error}</p>}
          <button type="button" disabled={!selected} onClick={handleRemove}>Remove patient</button>
          <button type="button" className="back-button" onClick={() => open('list')}>Back to patients</button>
        </div>
      )}
    </div>
  )
}

