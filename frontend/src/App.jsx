import { useEffect, useState } from 'react'
import './App.css'
import { api, setUnauthorizedHandler } from './api'
import Login from './Login'
import SignUp from './SignUp'
import PatientPortal from './PatientPortal'
import StaffDashboard from './StaffDashboard'

// The app's front door. It only decides WHICH part of the app to show:
//   not logged in -> Login or SignUp
//   Patient       -> PatientPortal (their own pages only)
//   staff roles   -> StaffDashboard (menu depends on the role)
export default function App() {
  const [account, setAccount] = useState(null)        // { username, role, ... } or null
  const [screen, setScreen] = useState('login')       // 'login' | 'signup' (only while logged out)
  const [checking, setChecking] = useState(true)      // true while we ask the API "am I logged in?"
  const [notice, setNotice] = useState('')            // message shown on the login card

  useEffect(() => {
    // Any 401 from a page = the login expired -> back to the login screen
    setUnauthorizedHandler(() => {
      setAccount(null)
      setScreen('login')
      setNotice('Your session ended. Please log in again.')
    })

    // After a page reload the cookie is still there, so ask who is logged in
    api.me()
      .then((me) => setAccount(me))
      .catch(() => setAccount(null))
      .finally(() => setChecking(false))
  }, [])

  function handleLoggedIn(loggedInAccount) {
    setNotice('')
    setAccount(loggedInAccount)
  }

  async function handleLogout() {
    try {
      await api.logout()
    } catch (error) {
      console.error('Logout request failed:', error)
    }
    setAccount(null)
    setScreen('login')
    setNotice('')
  }

  if (checking) {
    return <div className="Login-screen"><p className="loading-text">Loading…</p></div>
  }

  return (
    page == 'login' ?
    (
    <div className = "Login-screen"> {/* this is the name of the whole page */}
      <div className="login-intro"><span className="brand-mark" aria-hidden="true">+</span><p className="eyebrow">Medical Clinic</p><h1>Care starts with<br />a connected clinic.</h1><p>Your workspace for patient care, appointments, and clinic operations.</p></div><div className="login-panel"><div className="login-card"> {/*this is the smaller box that contains the title and password*/}
        <p className="eyebrow">Clinic portal</p><h1>Welcome back</h1><p>Sign in with your clinic account to continue.</p><label htmlFor="username">Username</label>       
        
        <input 
          type="text" 
          id="username" autoComplete="username" placeholder="Enter your username"
          value={Username}
          onChange={(event)=> setUsername(event.target.value)}
        />
        <label htmlFor="password">Password</label>
        <input 
          id="password" autoComplete="current-password" type="password" 
          placeholder='Password'
          value={Password}
          onChange={(event)=> setPassword(event.target.value)}
        />
        <button 
          type='button'
          onClick={handleLogin}>
          Log In
        </button>
      </div>
    </div></div>
        ) : (
          <div className='dashboard'><nav className="dashboard-nav" aria-label="Main navigation"><div className="nav-brand">+ Medical Clinic<span>Care management portal</span></div>
 
  <button aria-current={section === 'home' ? 'page' : undefined} onClick={() => setSection('home')}>
    Home
  </button>

 
  {(role === 'Admin' || role === 'Receptionist') && (
    <button aria-current={['patients', 'addPatient', 'editPatient', 'removePatient'].includes(section) ? 'page' : undefined} onClick={() => setSection('patients')}>
      Patients
    </button>
  )}

 
  {(role === 'Admin' || role === 'Receptionist') && (
    <button aria-current={section === 'payments' ? 'page' : undefined} onClick={() => setSection('payments')}>
      Payments
    </button>
  )}

  
  {(role === 'Admin' || role === 'Doctor' || role === 'Nurse') && (
    <button aria-current={section === 'reports' ? 'page' : undefined} onClick={() => setSection('reports')}>
      Reports
    </button>
  )}

  
  {(role === 'Admin' || role === 'Receptionist' || role === 'Doctor') && (
    <button aria-current={section === 'queries' ? 'page' : undefined} onClick={() => setSection('queries')}>
      Queries
    </button>
  )}

  
  {(
    role === 'Admin' ||
    role === 'Doctor' ||
    role === 'Nurse' ||
    role === 'Patient'
  ) && (
    <button aria-current={section === 'appointments' ? 'page' : undefined} onClick={() => setSection('appointments')}>
      Appointments
    </button>
  )}

  
  <button
    onClick={async () => {
      try {
        await api.logout();
      } catch (error) {
        console.error('Logout request failed:', error);
      }

      setRole('');
      setUsername('');
      setPassword('');
      setSection('home');
      setPage('login');
    }}
  >
    Log out
  </button>
</nav>
            <header className="workspace-header"><div><p className="eyebrow">Medical Clinic / Workspace</p><h1>{({home: 'Clinic overview', patients: 'Patients', payments: 'Payments', appointments: 'Appointments', reports: 'Reports', queries: 'Queries', addPatient: 'Add patient', editPatient: 'Edit patient', removePatient: 'Remove patient'})[section]}</h1></div><span className="role-badge">{role}</span></header>
            
            
           
            {section === 'home' && (
           <><div className="home-intro"><p className="eyebrow">Your clinic workspace</p><h2>Welcome, {Username}</h2><p>Choose a section to get started. Available tools are based on your clinic role.</p></div><div className="shortcut-grid">{[
['patients', 'Patients', 'Find and manage patient records.', ['Admin', 'Receptionist']],
['payments', 'Payments', 'Record payments for appointments.', ['Admin', 'Receptionist']],
['appointments', 'Appointments', 'View appointments and visit details.', ['Admin', 'Doctor', 'Nurse', 'Patient']],
['reports', 'Reports', 'Run clinic activity and patient reports.', ['Admin', 'Doctor', 'Nurse']],
['queries', 'Queries', 'Search records and review clinic information.', ['Admin', 'Receptionist', 'Doctor']],
].filter(([, , , roles]) => roles.includes(role)).map(([value, title, description]) => <button className="shortcut" key={value} onClick={() => setSection(value)}><strong>{title}</strong><span>{description}</span></button>)}</div></>
         )}
          {section === 'patients' && (
            <h2> Patient Management</h2>
            
          )}
          {section === 'payments' && (
            <h2> Payment Reports</h2>

         )}  
          {section === 'reports' && <Reports role={role} />}
          {section === 'queries' && <Queries role={role} />}
          {section === 'appointments' && 
          <Appointments role={role} />}
            
            {section === 'payments' && (
            <div className='payment-form'>
              <h2>Record Payment</h2>
              <label>Appointment ID</label>
              <input
                type="text"
                inputMode="numeric"
                maxLength={7}
                placeholder="Enter 7-digit Appointment ID"
                value={paymentAppointmentId}
                onChange={(e) => setPaymentAppointmentId(e.target.value)}
              />
              <label>Payment Amount ($)</label>
                <input
                type='number'
                placeholder='Enter Amount'
                min="0"
                step="0.01"
                value={paymentAmount}
                onChange={(e)=>setPaymentAmount(e.target.value)}
                />
            <label>Payment Date</label>
              <input type='date'
                 value={paymentDate}
                onChange={(e)=>setPaymentDate(e.target.value)}
              />

              <label>Payment Method</label>
              <select
                value={paymentMethod}
                onChange={(e) => setPaymentMethod(e.target.value)}
              >
                <option value="" disabled>Select Payment Method</option>
                <option value="1">Cash</option>
                <option value="2">Credit Card</option>
                <option value="3">Debit Card</option>
                <option value="4">Insurance</option>
                <option value="5">Check</option>
              </select>

              <label>Payment Status</label>
              <select
                value={paymentStatus}
                onChange={(e) => setPaymentStatus(e.target.value)}
              >
                <option value="" disabled>Select Status</option>
                <option value="Pending">Pending</option>
                <option value="Completed">Completed</option>
              </select>

              <label>Installment Number</label>
              <input
                type="number"
                min="1"
                max="2147483647"
                step="1"
                value={paymentInstallment}
                onChange={(e) => setPaymentInstallment(e.target.value)}
              />

              {paymentError && (
                <p role="alert" style={{ color: '#b00020' }}>
                  {paymentError}
                </p>
              )}

              <button
                type="button"
                onClick={handleRecordPayment}
                disabled={paymentSaving}
              >
                {paymentSaving ? 'Saving...' : 'Record Payment'}
              </button>

                  <button
                    type="button"
                    className='back-button'
                    onClick={()=> setSection('home')}
                    >
                      Back to dashboard
                    </button>
                    <h3>Recorded Payments</h3>

                    <table>
                      <thead>
                        <tr>
                          <th>Appointment ID</th>
                          <th>Amount</th>
                          <th>Date</th>
                          <th>Method</th>
                          <th>Status</th>
                        </tr>
                      </thead>

                      <tbody>
                        {payments.length === 0 && <tr><td colSpan="5" className="empty-state">No payments recorded in this session.</td></tr>}
                        {payments.map((payment,index)=>(
                          <tr key={index}>
                            <td>{payment.appointmentID}</td>
                            <td>${payment.amount.toFixed(2)}</td>
                            <td>{payment.date}</td>
                            <td>{payment.method}</td>
                            <td>{payment.status}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>

         )}  
            {section === 'patients' &&
             (
              <div className='Patient Management'>
            <button onClick={() => setSection('addPatient')}>
              Add Patient
              </button>

              <button onClick={() => setSection('editPatient')}>
              Edit Patient
              </button>

              <button onClick={() => setSection('removePatient')}>
              Remove Patient
              </button>
              
<h3>Patient List</h3>

<table>
  <thead>
    <tr>
      <th>Patient ID</th>
      <th>First Name</th>
      <th>Last Name</th>
      <th>Phone</th>
      <th>Email</th>
    </tr>
  </thead>

  <tbody>
    {patients.length === 0 ? (
      <tr>
        <td colSpan="5">No patients found.</td>
      </tr>
    ) : (
      patients.map((patient) => (
        <tr key={patient.patientID}>
          <td>{patient.patientID}</td>
          <td>{patient.firstName}</td>
          <td>{patient.lastName}</td>
          <td>{patient.phone}</td>
          <td>{patient.email}</td>
        </tr>
      ))
    )}
  </tbody>
</table>

              </div>
            )}
            {section === 'addPatient' && 
            (
              <div className='add-Patient'>
                <h2>Add New Patient</h2>
                <label>First Name</label>
                <input 
                  type="text"
                  placeholder='Enter First Name'
                  value={firstname}
                  onChange={(event)=>setFirstName(event.target.value)}
                  />
                  {formErrors.firstname &&(
                    <p className='field-error'>
                      {formErrors.firstname}
                    </p>
                  )}
                  <label>Middle Name (Optional) </label>
                  <input
                    type="text"
                    placeholder='Enter Middle Name'
                    value={middleName}
                    onChange={(event)=>setMiddleName(event.target.value)}
                    />
                <label>Last Name</label>
                <input
                  type="text"
                  placeholder='Enter Last Name'
                  value={lastName}
                  onChange={(event)=>setLastName(event.target.value)}
                  />
                  {formErrors.lastName &&(
                    <p className='field-error'>
                      {formErrors.lastName}
                    </p>
                  )}
                  <label>Street Address</label>
                  <input 
                    type="text"
                    placeholder='Enter Street Address'
                    value={streetAddress}
                    onChange={(event)=>setStreetAddress(event.target.value)}
                    />
                    {formErrors.streetAddress &&(
                    <p className='field-error'>
                      {formErrors.streetAddress}
                    </p>
                  )}
                  <label>Apartment Number (Optional)</label>
                    <input 
                      type="text"
                      placeholder='Enter Apartment Number'
                      value={apartmentNumber}
                      onChange={(event)=>setApartmentNumber(event.target.value)}
                      />
                  <label>City</label>
                    <input 
                      type="text"
                      placeholder='Enter City'
                      value={city}
                      onChange={(event)=>setCity(event.target.value)}
                      />
                      {formErrors.city &&(
                    <p className='field-error'>
                      {formErrors.city}
                    </p>
                  )}
                  <label>State</label>
                    <input  
                      type="text"
                      placeholder='Enter State'
                      value={state}
                      onChange={(event)=>setState(event.target.value)}
                      />
                      {formErrors.state &&(
                    <p className='field-error'>
                      {formErrors.state}
                    </p>
                  )}
                  <label>Zip code</label>
                  <input 
                  type='text'
                  placeholder='Enter Zipcode'
                  value={zipCode}
                  onChange={(event)=>setZipCode(event.target.value)}
                  />
                   {formErrors.zipCode &&(
                    <p className='field-error'>
                      {formErrors.zipCode}
                    </p>
                  )}
                  <label>Country</label>
                  <input
                  type='text'
                  placeholder='Enter Country'
                  value={country}
                  onChange={(event)=>setCountry(event.target.value)}
                  />
                   {formErrors.country &&(
                    <p className='field-error'>
                      {formErrors.country}
                    </p>
                  )}
                  <label>Phone number</label>
                  <input
                    type='tel'
                    placeholder='Enter Phone Number'
                    value={phone}
                    onChange={(event)=>setPhone(event.target.value)}
                    />
                    {formErrors.phone &&(
                    <p className='field-error'>
                      {formErrors.phone}
                    </p>
                  )}
                  <label>SSN</label>
                    <input
                      type='text'
                      placeholder='Enter SSN'
                      value={ssn}
                      onChange={(event)=>setSSN(event.target.value)}
                      />
                     {formErrors.ssn &&(
                    <p className='field-error'>
                      {formErrors.ssn}
                    </p>
                  )}
                  <label>Sex - M,F,or I </label>
                    <select 
                    value={sex}  
                    onChange={(event)=>setSex(event.target.value)}
                    >
                        <option value="" disabled>Select sex</option>
                        <option value="M">M</option>
                        <option value="F">F</option>
                        <option value="I">I</option>
                      </select>
                       {formErrors.sex &&(
                    <p className='field-error'>
                      {formErrors.sex}
                    </p>
                  )}
                  <label>Date of birth</label>
                  <input
                    type='date'
                    value={dateOfBirth}
                    onChange={(event)=>setDateOfBirth(event.target.value)}
                    />
                    {formErrors.dateOfBirth &&(
                    <p className='field-error'>
                      {formErrors.dateOfBirth}
                    </p>
                  )}
                    <label>Email</label>
                    <input 
                      type='email'
                      placeholder='Enter Email'
                      value={email}
                      onChange={(event)=>setEmail(event.target.value)}
                      />
                      {formErrors.email &&(
                    <p className='field-error'>
                      {formErrors.email}
                    </p>
                  )}
                  <button type ="button"
                    onClick={handleAddPatient}
                  >
                  Save
                </button>
              <button className="back-button" 
                onClick={() => setSection('patients')}
              >
                Back to Patients
                </button>
              </div> 

            )}
            {section ==='editPatient' && 
            (
              <div className='edit-Patient'>
                <h2>Edit Patient</h2>
                <label>Patient ID</label>
                <input  
                  type='text'
                  placeholder='Enter Patient ID'
                  value={editPatientId}
                  onChange={(event)=> setEditPatientId(event.target.value)}
                  />
                <button type ="button" onClick={handleSearchPatient}>
                  Search Patient
                </button>
                <h3> Patient Information</h3>
                <label>First Name</label>
               <input
                  type="text"
                  placeholder="Enter First Name"
                  value={firstname}
                  onChange={(event) => setFirstName(event.target.value)}
                />

                <label>Middle Name</label>
                <input
                  type="text"
                  placeholder="Enter Middle Name"
                  value={middleName}
                  onChange={(event) => setMiddleName(event.target.value)}
                />

                <label>Last Name</label>
                <input
                  type="text"
                  placeholder="Enter Last Name"
                  value={lastName}
                  onChange={(event) => setLastName(event.target.value)}
                />

                <label>Phone Number</label>
                <input 
                  type ="text" 
                  placeholder="enter Phone number"
                  value={phone}
                  onChange={(event) => setPhone(event.target.value)}
                />

                <label>Email</label>
                <input 
                  type ="text" 
                  placeholder="enter Email"
                  value={email}
                  onChange={(event) => setEmail(event.target.value)}
                  />
                <label>Street Address</label>
                <input 
                  type ="text" 
                  placeholder="enter Address"
                  value={streetAddress}
                  onChange={(event) => setStreetAddress(event.target.value)}
                />

                <label>City</label>
                <input 
                  type ="text" 
                  placeholder="enter City"
                  value={city}
                  onChange={(event) => setCity(event.target.value)}
                />

                <label>State</label>
                <input 
                  type ="text" 
                  placeholder="enter State"
                  value={state}
                  onChange={(event) => setState(event.target.value)}
                />

                <label>Zipcode</label>
                <input 
                  type ="text" 
                  placeholder="enter Zipcode"
                  value={zipCode}
                  onChange={(event) => setZipCode(event.target.value)}
                />
                <button type ="button" onClick={handleUpdatePatient}>
                  Save
                </button>

                <button
                  className='back-button'
                  onClick={()=>setSection('patients')}
                >
                  Back to Patients
                </button>
                </div>
            )}
            {section === 'removePatient' &&
            (
              <div className='remove-patient'>
                <h2>Remove Patient</h2>

                
                <label>Patient ID</label>
                <input
                  type="text"
                  placeholder="Enter Patient ID"
                  value={removePatientId}
                  onChange={(event) => {
                    setRemovePatientId(event.target.value);
                    setPatientToRemove(null);
                  }}
                />

                <button
                  type="button"
                  onClick={handleSearchRemovePatient}
                >
                  Search Patient
                </button>

              {patientToRemove  && (
                <div>
                  <h3>Patient Found</h3>
                <p>
                  ID: {patientToRemove.patientID}
                </p>
                <p>
                  Name: {patientToRemove.firstName} {patientToRemove.lastName}
                </p>
                <p>
                  Phone: {patientToRemove.phone}
                </p>
                <p>
                  Email: {patientToRemove.email}
                </p>
                </div>
              )}
