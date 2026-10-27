import { useEffect, useState } from 'react'
import { api } from './api'

const emptyForm = {
  firstName: '', middleName: '', lastName: '',
  dateOfBirth: '', sex: '', ssn: '',
  phone: '', email: '',
  streetAddress: '', apartmentNum: '', city: '', state: '', zipCode: '', country: 'USA',
  primaryDoctorID: '',
  username: '', password: '', confirmPassword: '',
}

// Same rules as RegisterPatientRequest.cs, checked here first so the user
// sees every problem at once instead of one server error at a time.
function validate(form) {
  const errors = {}
  const required = {
    firstName: 'first name', lastName: 'last name', dateOfBirth: 'date of birth',
    sex: 'sex', ssn: 'SSN', phone: 'phone number', email: 'email',
    streetAddress: 'street address', city: 'city', state: 'state', zipCode: 'ZIP code',
    country: 'country', primaryDoctorID: 'primary doctor', username: 'username', password: 'password',
  }
  Object.entries(required).forEach(([field, label]) => {
    if (form[field].trim() === '') errors[field] = `Enter your ${label}.`
  })

  if (/[0-9]/.test(form.firstName + form.middleName + form.lastName)) {
    errors.firstName = 'Names cannot contain numbers.'
  }
  if (form.ssn && !/^[0-9]{3}-[0-9]{2}-[0-9]{4}$/.test(form.ssn)) {
    errors.ssn = 'Use the format 123-45-6789.'
  }
  if (form.phone && !/^[0-9]{10}$/.test(form.phone)) {
    errors.phone = 'Ten digits, no spaces or dashes.'
  }
  if (form.zipCode && !/^[0-9]{5}$/.test(form.zipCode)) {
    errors.zipCode = 'Five digits.'
  }
  if (form.email && !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(form.email)) {
    errors.email = 'Enter a valid email address.'
  }
  if (form.dateOfBirth && form.dateOfBirth > new Date().toLocaleDateString('en-CA')) {
    errors.dateOfBirth = 'Date of birth cannot be in the future.'
  }
  if (form.username && !/^[A-Za-z0-9._-]{4,25}$/.test(form.username)) {
    errors.username = '4 to 25 characters: letters, numbers, dots, dashes or underscores.'
  }
  if (form.password && (form.password.length < 8 || form.password.length > 72)) {
    errors.password = 'Password must be 8 to 72 characters long.'
  }
  if (form.password !== form.confirmPassword) {
    errors.confirmPassword = 'Passwords do not match.'
  }
  return errors
}

export default function SignUp({ onLoggedIn, onBack }) {
  const [form, setForm] = useState(emptyForm)
  const [errors, setErrors] = useState({})
  const [doctors, setDoctors] = useState([])
  const [serverError, setServerError] = useState('')
  const [busy, setBusy] = useState(false)

  useEffect(() => {
    // Public list (no login needed): GET /api/lookups/primary-doctors
    api.get('/lookups/primary-doctors')
      .then(setDoctors)
      .catch((e) => setServerError(`Could not load the doctor list: ${e.message}`))
  }, [])

  function update(field, value) {
    setForm({ ...form, [field]: value })
  }

  async function handleSubmit() {
    setServerError('')
    const found = validate(form)
    setErrors(found)
    if (Object.keys(found).length > 0) return

    const body = {
      ssn: form.ssn,
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
      username: form.username,
      password: form.password,
      primaryDoctorID: Number(form.primaryDoctorID),
    }

    setBusy(true)
    try {
      await api.register(body)                                  // creates the 4 rows
      const account = await api.login(form.username, form.password)   // then logs in
      onLoggedIn(account)
    } catch (e) {
      setServerError(e.message)                                 // e.g. "That username is already taken."
    } finally {
      setBusy(false)
    }
  }

  // One label + input + error message
  function field(name, label, props = {}) {
    return (
      <div className="form-field">
        <label htmlFor={name}>{label}</label>
        <input
          id={name}
          value={form[name]}
          onChange={(e) => update(name, e.target.value)}
          {...props}
        />
        {errors[name] && <p className="field-error">{errors[name]}</p>}
      </div>
    )
  }

  return (
    <div className="Login-screen">
      <div className="signup-card">
        <h1>Create your patient account</h1>
        <p className="signup-intro">
          Fill in your details once. After that you can book and manage your own appointments online.
        </p>

        <h3>About you</h3>
        <div className="form-grid">
          {field('firstName', 'First name', { maxLength: 15 })}
          {field('middleName', 'Middle name (optional)', { maxLength: 15 })}
          {field('lastName', 'Last name', { maxLength: 31 })}
          {field('dateOfBirth', 'Date of birth', { type: 'date' })}
          <div className="form-field">
            <label htmlFor="sex">Sex</label>
            <select id="sex" value={form.sex} onChange={(e) => update('sex', e.target.value)}>
              <option value="">Select</option>
              <option value="F">Female</option>
              <option value="M">Male</option>
              <option value="I">Intersex</option>
            </select>
            {errors.sex && <p className="field-error">{errors.sex}</p>}
          </div>
          {field('ssn', 'SSN', { placeholder: '123-45-6789', maxLength: 11 })}
        </div>

        <h3>Contact</h3>
        <div className="form-grid">
          {field('phone', 'Phone (10 digits)', { type: 'tel', placeholder: '7135551234', maxLength: 10 })}
          {field('email', 'Email', { type: 'email', maxLength: 100 })}
          {field('streetAddress', 'Street address', { maxLength: 80 })}
          {field('apartmentNum', 'Apartment (optional)', { maxLength: 5 })}
          {field('city', 'City', { maxLength: 48 })}
          {field('state', 'State', { maxLength: 20 })}
          {field('zipCode', 'ZIP code', { maxLength: 5 })}
          {field('country', 'Country', { maxLength: 56 })}
        </div>

        <h3>Your primary doctor</h3>
        <div className="form-field">
          <label htmlFor="primaryDoctorID">Primary care doctor</label>
          <select
            id="primaryDoctorID"
            value={form.primaryDoctorID}
            onChange={(e) => update('primaryDoctorID', e.target.value)}
          >
            <option value="">Select a doctor</option>
            {doctors.map((d) => (
              <option key={d.id} value={d.id}>{d.name}</option>
            ))}
          </select>
          {errors.primaryDoctorID && <p className="field-error">{errors.primaryDoctorID}</p>}
          <p className="field-hint">You can book visits with this doctor. Specialists need a referral from them.</p>
        </div>

        <h3>Login details</h3>
        <div className="form-grid">
          {field('username', 'Username', { maxLength: 25, autoComplete: 'username' })}
          <div />
          {field('password', 'Password (8+ characters)', { type: 'password', maxLength: 72, autoComplete: 'new-password' })}
          {field('confirmPassword', 'Confirm password', { type: 'password', maxLength: 72, autoComplete: 'new-password' })}
        </div>

        {serverError && <p className="error-message">{serverError}</p>}

        <button type="button" className="primary-button" onClick={handleSubmit} disabled={busy}>
          {busy ? 'Creating account…' : 'Create account'}
        </button>
        <button type="button" className="link-button" onClick={onBack}>
          Already have an account? Log in
        </button>
      </div>
    </div>
  )
}
