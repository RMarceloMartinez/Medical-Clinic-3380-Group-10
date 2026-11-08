import { useEffect, useState } from 'react'
import { api } from '../../api/client'
import DataTable from '../../components/DataTable'

// Admin's Staff page: see every employee, and add a doctor, nurse or receptionist with a login.
// One screen at a time: list -> add -> back to list
const DAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']

const emptyWorker = {
  role: '', officeID: '', licenseNum: '', specialty: '', workDays: [],
  firstName: '', middleName: '', lastName: '', dateOfBirth: '', sex: '', ssn: '',
  phone: '', email: '', streetAddress: '', apartmentNum: '', city: '', state: '', zipCode: '', country: '',
  username: '', password: '',
}

function formatDate(value) {
  return value ? new Date(value).toLocaleDateString([], { month: 'short', day: 'numeric', year: 'numeric' }) : ''
}

const columns = [
  { key: 'name', label: 'Name' },
  { key: 'role', label: 'Role' },
  { key: 'office', label: 'Office', format: (r) => r.office ?? '—' },
  { key: 'specialty', label: 'Specialty and days',
    format: (r) => (r.specialty ? `${r.specialty} · ${r.workDays ?? 'no days set'}` : '—') },
  { key: 'username', label: 'Login', format: (r) => r.username ?? 'No login' },
  { key: 'hiringDate', label: 'Hired', format: (r) => formatDate(r.hiringDate), sortValue: (r) => r.hiringDate },
]

// Checks the form before sending, so each problem shows next to its field
function validate(form) {
  const errors = {}
  const required = {
    role: 'Choose a role.', officeID: 'Choose an office.',
    firstName: 'Enter the first name.', lastName: 'Enter the last name.',
    dateOfBirth: 'Enter the date of birth.', sex: 'Choose the sex.', ssn: 'Enter the SSN.',
    phone: 'Enter the phone number.', email: 'Enter the email.',
    streetAddress: 'Enter the street address.', city: 'Enter the city.', state: 'Enter the state.',
    zipCode: 'Enter the ZIP code.', country: 'Enter the country.',
    username: 'Enter a username.', password: 'Enter a temporary password.',
  }
  Object.entries(required).forEach(([field, text]) => {
    if (String(form[field]).trim() === '') errors[field] = text
  })

  const today = new Date().toLocaleDateString('en-CA')   // "2026-11-08", same shape as the date input
  if (form.dateOfBirth && form.dateOfBirth > today) errors.dateOfBirth = "Date of birth can't be in the future."
  if (form.ssn && !/^[0-9]{3}-[0-9]{2}-[0-9]{4}$/.test(form.ssn)) errors.ssn = 'Use the format 123-45-6789.'
  if (form.phone && !/^[0-9]{10}$/.test(form.phone)) errors.phone = 'Ten digits, no dashes or spaces.'
  if (form.zipCode && !/^[0-9]{5}$/.test(form.zipCode)) errors.zipCode = 'Five digits.'
  if (form.email && !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(form.email)) errors.email = 'Enter a valid email.'
  if (form.username && !/^[A-Za-z0-9._-]{4,25}$/.test(form.username)) {
    errors.username = '4 to 25 letters, numbers, dots, dashes or underscores.'
  }
  if (form.password && form.password.length < 8) errors.password = 'At least 8 characters.'

  if ((form.role === 'Doctor' || form.role === 'Nurse') && form.licenseNum.trim() === '') {
    errors.licenseNum = 'Enter the license number.'
  }
  if (form.role === 'Nurse' && form.licenseNum.trim().length > 10) {
    errors.licenseNum = 'A nurse license number has at most 10 characters.'
  }
  if (form.role === 'Doctor' && form.specialty === '') errors.specialty = 'Choose a specialty.'
  if (form.role === 'Doctor' && form.workDays.length === 0) errors.workDays = 'Pick at least one work day.'
  return errors
}

// The JSON the API expects (CreateEmployeeRequest); fields a role doesn't use are sent empty
function toRequestBody(form) {
  return {
    role: form.role,
    officeID: Number(form.officeID),
    licenseNum: form.role === 'Receptionist' ? null : form.licenseNum.trim(),
    specialty: form.role === 'Doctor' ? form.specialty : null,
    workDays: form.role === 'Doctor' ? DAYS.filter((d) => form.workDays.includes(d)) : [],
    ssn: form.ssn.trim(),
    firstName: form.firstName.trim(),
    middleName: form.middleName.trim() || null,
    lastName: form.lastName.trim(),
    streetAddress: form.streetAddress.trim(),
    apartmentNum: form.apartmentNum.trim() || null,
    city: form.city.trim(),
    state: form.state.trim(),
    zipCode: form.zipCode,
    country: form.country.trim(),
    phone: form.phone,
    sex: form.sex,
    dateOfBirth: form.dateOfBirth,
    email: form.email.trim(),
    username: form.username.trim(),
    password: form.password,
  }
}

export default function Staff() {
  const [view, setView] = useState('list')        // 'list' | 'add'
  const [employees, setEmployees] = useState([])
  const [offices, setOffices] = useState([])
  const [specialties, setSpecialties] = useState([])
  const [form, setForm] = useState(emptyWorker)
  const [errors, setErrors] = useState({})
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [message, setMessage] = useState('')
  const [error, setError] = useState('')

  useEffect(() => {
    async function loadAll() {
      try {
        const [staff, officeList, specialtyList] = await Promise.all([
          api.get('/employees'),
          api.get('/lookups/offices'),
          api.get('/employees/specialties'),
        ])
        setEmployees(staff)
        setOffices(officeList)
        setSpecialties(specialtyList)
      } catch (e) {
        setError(`Could not load the staff list: ${e.message}`)
      } finally {
        setLoading(false)
      }
    }
    loadAll()
  }, [])

  function update(name, value) {
    setForm((f) => ({ ...f, [name]: value }))
    setErrors((errs) => ({ ...errs, [name]: undefined }))   // the field changed, so its old error goes away
  }

  function toggleDay(day) {
    setForm((f) => ({
      ...f,
      workDays: f.workDays.includes(day) ? f.workDays.filter((d) => d !== day) : [...f.workDays, day],
    }))
    setErrors((errs) => ({ ...errs, workDays: undefined }))
  }

  function open(nextView) {
    setView(nextView)
    setError('')
    if (nextView === 'add') {
      setMessage('')
      setForm(emptyWorker)
      setErrors({})
    }
  }

  async function handleSave() {
    if (saving) return
    setError('')
    setMessage('')

    const found = validate(form)
    setErrors(found)
    if (Object.keys(found).length > 0) {
      setError('Some fields need fixing. Check the messages under them.')
      return
    }

    setSaving(true)
    try {
      await api.post('/employees', toRequestBody(form))

      const office = offices.find((o) => o.id === Number(form.officeID))
      const job = form.role === 'Doctor'
        ? `a ${form.specialty} doctor at ${office.name} (${DAYS.filter((d) => form.workDays.includes(d)).join(', ')})`
        : `a ${form.role.toLowerCase()} at ${office.name}`
      setMessage(`Added ${form.firstName.trim()} ${form.lastName.trim()} as ${job}. They can sign in as "${form.username.trim()}" with the temporary password you set.`)

      setEmployees(await api.get('/employees'))
      setForm(emptyWorker)
      setView('list')
    } catch (e) {
      setError(e.message)
    } finally {
      setSaving(false)
    }
  }

  // One label + input + its error, in a grid cell
  function field(name, label, props = {}) {
    return (
      <div className="form-field">
        <label htmlFor={`staff-${name}`}>{label}</label>
        <input id={`staff-${name}`} value={form[name]} onChange={(e) => update(name, e.target.value)} {...props} />
        {errors[name] && <p className="field-error">{errors[name]}</p>}
      </div>
    )
  }

  return (
    <div className="staff-page">
      <h2>Staff</h2>

      <div className="page-actions">
        <button type="button" className={view === 'list' ? 'active' : ''} onClick={() => open('list')}>
          All staff
        </button>
        <button type="button" className={view === 'add' ? 'active' : ''} onClick={() => open('add')}>
          Add worker
        </button>
      </div>

      {message && <p className="success-message">{message}</p>}
      {error && <p role="alert" className="error-message">{error}</p>}

      {view === 'list' && (
        loading ? (
          <p>Loading…</p>
        ) : (
          <DataTable
            columns={columns}
            rows={employees}
            rowKey={(r) => r.employeeID}
            filterLabel="Filter staff"
            emptyMessage="No employees found."
          />
        )
      )}

      {view === 'add' && (
        <div className="panel panel-wide">
          <h3>Job</h3>
          <div className="form-grid">
            <div className="form-field">
              <label htmlFor="staff-role">Role</label>
              <select id="staff-role" value={form.role} onChange={(e) => update('role', e.target.value)}>
                <option value="">Choose a role</option>
                <option value="Doctor">Doctor</option>
                <option value="Nurse">Nurse</option>
                <option value="Receptionist">Receptionist</option>
              </select>
              {errors.role && <p className="field-error">{errors.role}</p>}
            </div>

            <div className="form-field">
              <label htmlFor="staff-officeID">Office</label>
              <select id="staff-officeID" value={form.officeID} onChange={(e) => update('officeID', e.target.value)}>
                <option value="">Choose an office</option>
                {offices.map((o) => (
                  <option key={o.id} value={o.id}>{o.name}</option>
                ))}
              </select>
              {errors.officeID && <p className="field-error">{errors.officeID}</p>}
            </div>

            {(form.role === 'Doctor' || form.role === 'Nurse') &&
              field('licenseNum', 'License number', { maxLength: form.role === 'Nurse' ? 10 : 11 })}

            {form.role === 'Doctor' && (
              <div className="form-field">
                <label htmlFor="staff-specialty">Specialty</label>
                <select id="staff-specialty" value={form.specialty} onChange={(e) => update('specialty', e.target.value)}>
                  <option value="">Choose a specialty</option>
                  {specialties.map((s) => (
                    <option key={s.name} value={s.name}>{s.name} (visit ${Number(s.visitFee).toFixed(0)})</option>
                  ))}
                </select>
                {errors.specialty && <p className="field-error">{errors.specialty}</p>}
              </div>
            )}
          </div>

          {form.role === 'Doctor' && (
            <fieldset className="form-field">
              <legend>Work days at this office</legend>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '1rem' }}>
                {DAYS.map((day) => (
                  <label key={day} style={{ display: 'flex', alignItems: 'center', gap: '0.35rem' }}>
                    <input type="checkbox" checked={form.workDays.includes(day)} onChange={() => toggleDay(day)} />
                    {day}
                  </label>
                ))}
              </div>
              {errors.workDays && <p className="field-error">{errors.workDays}</p>}
            </fieldset>
          )}

          <h3>Person</h3>
          <div className="form-grid">
            {field('firstName', 'First name', { maxLength: 15 })}
            {field('middleName', 'Middle name (optional)', { maxLength: 15 })}
            {field('lastName', 'Last name', { maxLength: 31 })}
            {field('dateOfBirth', 'Date of birth', { type: 'date' })}
            <div className="form-field">
              <label htmlFor="staff-sex">Sex</label>
              <select id="staff-sex" value={form.sex} onChange={(e) => update('sex', e.target.value)}>
                <option value="">Select sex</option>
                <option value="M">M</option>
                <option value="F">F</option>
                <option value="I">I</option>
              </select>
              {errors.sex && <p className="field-error">{errors.sex}</p>}
            </div>
            {field('ssn', 'SSN', { placeholder: '123-45-6789', maxLength: 11 })}
            {field('phone', 'Phone number', { type: 'tel', maxLength: 10 })}
            {field('email', 'Email', { type: 'email', maxLength: 100 })}
            {field('streetAddress', 'Street address', { maxLength: 80 })}
            {field('apartmentNum', 'Apartment number (optional)', { maxLength: 5 })}
            {field('city', 'City', { maxLength: 48 })}
            {field('state', 'State', { maxLength: 20 })}
            {field('zipCode', 'ZIP code', { maxLength: 5 })}
            {field('country', 'Country', { maxLength: 56 })}
          </div>

          <h3>Login</h3>
          <div className="form-grid">
            {field('username', 'Username', { maxLength: 25, autoComplete: 'off' })}
            {field('password', 'Temporary password', { type: 'password', maxLength: 72, autoComplete: 'new-password' })}
          </div>
          <p className="field-hint">Give the new worker this username and temporary password. They sign in on the same page as everyone else.</p>

          <div className="page-actions">
            <button type="button" className="primary-button" onClick={handleSave} disabled={saving}>
              {saving ? 'Saving…' : 'Add worker'}
            </button>
            <button type="button" onClick={() => open('list')} disabled={saving}>Cancel</button>
          </div>
        </div>
      )}
    </div>
  )
}