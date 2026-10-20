import { useState } from 'react'
import './App.css'

function App() {
  const[page, setPage] = useState('login')
  const[section, setSection] = useState('home')
  const [Username, setUsername] = useState('')
  const [Password, setPassword] = useState('')
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
                  />
                <label>Last Name</label>
                <input
                  type="text"
                  placeholder='Enter last name'
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
