import { useState } from 'react'
import './App.css'

function App() {
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
    alert("both fields are filled in")
  }

  return (
        <div className = "Login-screen"> {/* this is the name of the whole page */}
          <div className="login-card"> {/*this is the smaller box that contains the title and password*/}
          <h1>Medical Clinic</h1>      
          <p>
            Patient Management System
          </p>
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
          <button type='button'
          onClick={handleLogin}>
          
            Log In
            </button>
        </div>
        </div>
        )
}

export default App
