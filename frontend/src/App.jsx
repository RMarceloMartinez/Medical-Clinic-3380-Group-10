import { useState } from 'react'
import './App.css'

function App() {
  const[page, setPage] = useState('login')
  const[section, setSection] = useState('home')
  const [Username, setUsername] = useState('')
  const [Password, setPassword] = useState('')
  const [firstname,setFirstName]=useState('')
  const [middleName,setMiddleName]=useState('')
  const [lastName,setLastName]=useState('')
  const [streetAddress,setStreetAddress]=useState('')
  const [apartmentNumber,setApartmentNumber]=useState('')
  const [city,setCity]=useState('')
  const [state,setState]=useState('')
  const [zipCode,setZipCode]=useState('')
  const [country,setCountry]=useState('')
  const [phone,setPhone]=useState('')
  const [ssn,setSSN]=useState('')
  const[sex,setSex]=useState('')
  const [dateOfBirth,setDateOfBirth]=useState('')
  const [email,setEmail]=useState('')
  const [formErrors,setFormErrors]=useState({})

  function handleLogin()
  {
    if(Username==='')
    {
      alert('Please enter your username')
      return
    }
    if(Password==='')
    {
      alert('Please enter your password')
      return
    }
    setPage('Dashboard')
  }
  function handleAddPatient()
  {
    const errors = {}
    if(firstname==='')
    {
      errors.firstname= 'Please enter the First name'
    
    }
    if(lastName==='')
    {
     errors.lastName= 'Please enter the last name'
      
    }
    if(email ==='' && !email.includes('@'))
    {
      errors.email= 'Please enter a valid email'
      
    }
    if(phone==='')
    {
     errors.phone= 'Please enter the phone number'
      
    }
    if(dateOfBirth==='')
    {
      errors.dateOfBirth= 'Please enter the date of birth'
      
    }
    if(city==='')
    {
     errors.city= 'Please enter the city'
      
    }
    if(state==='')
    {
     errors.state= 'Please enter the state'
      
    }
    if(zipCode==='')
    {
     errors.zipCode= 'Please enter the zipcode'
      
    }
    if(country==='')
    {
     errors.country= 'Please enter the country'
      
    }
    if(ssn==='')
    {
     errors.ssn= 'Please enter the ssn'
      
    }
    if(sex==='')
    {
     errors.sex= 'Please enter the sex'
      
    }
    if(streetAddress==='')
    {
     errors.streetAddress= 'Please enter the Street address'
      
    }
    setFormErrors(errors)
    if(Object.keys(errors).length >0)
    {
      return
    }
    alert('Patient information is filled in!')
  }

  return (
    page == 'login' ?
    (
    <div className = "Login-screen"> {/* this is the name of the whole page */}
      <div className="login-card"> {/*this is the smaller box that contains the title and password*/}
        <h1>Medical Clinic</h1>       
        
        <input 
          type="text" 
          placeholder='Username'
          value={Username}
          onChange={(event)=> setUsername(event.target.value)}
        />
        <input 
          type='password' 
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
    </div>
        ) : (
          <div className='dashboard'>
            <h1>Medical Clinic Dashboard</h1>
            
            <p>Welcome to the dashboard</p>
           
            {section === 'home' && (
           <p>Select a section to get started</p>
         )}
          {section === 'patients' && (
            <h2> Patient Management</h2>
            
          )}
          {section === 'payments' && (
            <h2> Payment Reports</h2>

         )}  
         {section === 'reports' && (
            <h2> Clinic Reports</h2>
          )}
          {section === 'appointments' && (
            <h2> Appointment Management</h2>
          )}
            <div className='dashboard-nav'>
               <button onClick={() => setSection('home')}>
              Home
            </button>
              <button onClick={()=> setSection('patients')}>
              Patients
            </button>
            <button onClick={()=> setSection('payments')}>
              Payments
            </button>
            <button onClick={()=> setSection('reports')}>
              Reports
            </button>
            <button onClick={()=> setSection('appointments')}>
              Appointments
            </button>
            <button onClick={()=> setPage('login')}>
              Log out
            </button>
            </div>
            {section === 'payments' && (
            <div className='payment-form'>
              <h2>Record Payment</h2>
              <label>Patient ID</label>
              <input 
                type='text'
                placeholder='Enter Patient ID'
                />
              <label>Payment Amount ($)</label>
                <input
                type='number'
                placeholder='Enter Amount'
                min="0"
                step="0.01"
                />
            <label>Payment Date</label>
              <input type='date'/>

              <label> Payment methods</label>
                <select defaultValue="">
                  <option value="" disabled>
                    Select Payment Method
                  </option>
                  <option value="cash">Cash</option>
                  <option value="credit">Credit</option>
                  <option value="debit">Debit</option>
                  <option value="insurance">Insurance</option>
                </select>

                <label>Payment Status</label>
                  <select defaultValue="">
                    <option value="" disabled>
                      Select Status
                    </option>
                    <option value="pending">Pending</option>
                    <option value="paid">Paid</option>
                    <option value="failed">Failed</option>
                  </select>

                  <button type='button'>
                    Record Payment
                  </button>

                  <button
                    type="button"
                    className='back-button'
                    onClick={()=> setSection('home')}
                    >
                      Back to dashboard
                    </button>
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
                  />
                <button type ="button">
                  Search Patient
                </button>
                <h3> Patient Information</h3>
                <label>First Name</label>
                <input type ="text" placeholder="enter first name"/>

                <label>Middle Name</label>
                <input type ="text" placeholder="enter Middle name"/>

                <label>Last Name</label>
                <input type ="text" placeholder="enter Last name"/>

                <label>Phone Number</label>
                <input type ="text" placeholder="enter Phone number"/>

                <label>Email</label>
                <input type ="text" placeholder="enter Email"/>

                <label>Street Address</label>
                <input type ="text" placeholder="enter Address"/>

                <label>City</label>
                <input type ="text" placeholder="enter City"/>

                <label>State</label>
                <input type ="text" placeholder="enter State"/>

                <label>Zipcode</label>
                <input type ="text" placeholder="enter Zipcode"/>
                <button type ="button">
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
                type='text'
                placeholder='Enter Patient ID'
                />

                <button type='button'>
                  Search Patient
                </button>

                <button type='button'>
                  Remove Patient
                </button>
                <button type ="button">
                  Save
                </button>
                <button
                  className='back-button'
                  onClick={() => setSection('patients')}
                  >
                    Back to Patients
                  </button>
                  </div>
            ) }
          </div>
        )
  )
}

export default App
