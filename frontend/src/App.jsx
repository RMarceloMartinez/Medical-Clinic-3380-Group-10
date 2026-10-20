import { use, useState } from 'react'
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
            <h2> Payments Management</h2>
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
            {section === 'patients' &&
             (
            <button onClick={() => setSection('addPatient')}>
              Add Patient
              </button>
            )}
            {section === 'addPatient' && 
            (
              <div>
                <h2>Add New Patient</h2>
                <label>First Name</label>
                <input 
                  type="text"
                  placeholder='Enter first name'
                  value={firstname}
                  onChange={(event)=>setFirstName(event.target.value)}
                  />
                  <label>Middle Name (Optional) </label>
                  <input
                    type="text"
                    placeholder='Enter middle name'
                    value={middleName}
                    onChange={(event)=>setMiddleName(event.target.value)}
                    />
                <label>Last Name</label>
                <input
                  type="text"
                  placeholder='Enter last name'
                  value={lastName}
                  onChange={(event)=>setLastName(event.target.value)}
                  />
                  <label>Street Address</label>
                  <input 
                    type="text"
                    placeholder='Enter street address'
                    value={streetAddress}
                    onChange={(event)=>setStreetAddress(event.target.value)}
                    />
                  <label>Apartment Number (Optional)</label>
                    <input 
                      type="text"
                      placeholder='Enter apartment number'
                      value={apartmentNumber}
                      onChange={(event)=>setApartmentNumber(event.target.value)}
                      />
                  <label>City</label>
                    <input 
                      type="text"
                      placeholder='Enter city'
                      value={city}
                      onChange={(event)=>setCity(event.target.value)}
                      />
                  <lable>State</lable>
                    <input  
                      type="text"
                      placeholder='Enter state'
                      value={state}
                      onChange={(event)=>setState(event.target.value)}
                      />
                  <label>Zip code</label>
                  <input 
                  type='text'
                  placeholder='Enter zip code'
                  value={zipCode}
                  onChange={(event)=>setZipCode(event.target.value)}
                  />
                  <label>Country</label>
                  <input
                  type='text'
                  placeholder='Enter country'
                  value={country}
                  onChange={(event)=>setCountry(event.target.value)}
                  />
                  <label>Phone number</label>
                  <input
                    type='tel'
                    placeholder='Enter phone number'
                    value={phone}
                    onChange={(event)=>setPhone(event.target.value)}
                    />
                  <label>SSN</label>
                    <input
                      type='text'
                      placeholder='Enter SSN'
                      value={ssn}
                      onChange={(event)=>setSSN(event.target.value)}
                      />
                    
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
                  <label>Date of birth</label>
                  <input
                    type='date'
                    value={dateOfBirth}
                    onChange={(event)=>setDateOfBirth(event.target.value)}
                    />
                    <label>Email</label>
                    <input 
                      type='email'
                      placeholder='Enter Email'
                      value={email}
                      onChange={(event)=>setEmail(event.target.value)}
                      />
                  
              <button className="back-button" 
                onClick={() => setSection('patients')}
              >
                Back to Patients
                </button>
              </div> 

            )}
          </div>
        )
  )
}

export default App
