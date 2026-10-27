import { useState, useEffect } from 'react'
import './App.css'
import { api } from './api'
import Appointments from './Appointments'
import Reports from './Reports'

function App() {
  const [page, setPage] = useState('login')
  const [section, setSection] = useState('home')
  const [Username, setUsername] = useState('')
  const [Password, setPassword] = useState('')
  const [role, setRole] = useState('')
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
  const [sex,setSex]=useState('')
  const [dateOfBirth,setDateOfBirth]=useState('')
  const [email,setEmail]=useState('')
  const [formErrors,setFormErrors]=useState({})
  const [paymentPatientId,setPatientId]=useState('')
  const [paymentAmount,setPaymentAmount]=useState('')
  const [paymentDate, setPaymentDate]=useState('')
  const [paymentMethod, setPaymentMethod]=useState('')
  const [paymentStatus, setPaymentStatus]=useState('')
  const [payments, setPayments]= useState([]);
  const [patients, setPatients] = useState([]);
  const [editPatientId, setEditPatientId] = useState('');
  const [selectedPatient, setSelectedPatient] = useState(null);
  const [removePatientId, setRemovePatientId] = useState('');
  const [patientToRemove, setPatientToRemove] = useState(null);
  
  
async function handleRemovePatient() {
  if (!patientToRemove) {
    alert('Search for a patient first.');
    return;
  }

  const confirmed = window.confirm(
    `Are you sure you want to remove ${patientToRemove.firstName} ${patientToRemove.lastName}?`
  );

  if (!confirmed) return;

  try {
    await api.delete(`/patients/${removePatientId}`);

    alert('Patient removed successfully!');
    setPatientToRemove(null);
    setRemovePatientId('');
    await loadPatients();
  } catch (error) {
    alert(`Could not remove patient: ${error.message}`);
  }
}

async function handleSearchRemovePatient() {
  if (!removePatientId.trim()) {
    alert('Please enter a Patient ID');
    return;
  }

  try {
    const patient = await api.get(`/patients/${removePatientId}`);
    setPatientToRemove(patient);
  } catch (error) {
    setPatientToRemove(null);
    alert(`Could not find patient: ${error.message}`);
  }
}

async function handleUpdatePatient() {
  if (!selectedPatient) {
    alert('Search for a patient before saving changes.');
    return;
  }

  const updatedPatient = {
    SSN: ssn,
    FirstName: firstname,
    MiddleName: middleName || null,
    LastName: lastName,
    StreetAddress: streetAddress,
    ApartmentNum: apartmentNumber || null,
    City: city,
    State: state,
    ZipCode: zipCode,
    Country: country,
    Phone: phone,
    Sex: sex,
    DateOfBirth: dateOfBirth,
    Email: email
  };

  try {
    await api.put(`/patients/${editPatientId}`, updatedPatient);

    alert('Patient updated successfully!');
    await loadPatients();
  } catch (error) {
    alert(`Could not update patient: ${error.message}`);
  }
}

async function handleSearchPatient() {
  if (!editPatientId.trim()) {
    alert('Please enter a Patient ID');
    return;
  }

  try {
    const patient = await api.get(`/patients/${editPatientId}`);

    setSelectedPatient(patient);

    setFirstName(patient.firstName ?? '');
    setMiddleName(patient.middleName ?? '');
    setLastName(patient.lastName ?? '');
    setPhone(patient.phone ?? '');
    setEmail(patient.email ?? '');
    setStreetAddress(patient.streetAddress ?? '');
    setApartmentNumber(patient.apartmentNum ?? '');
    setCity(patient.city ?? '');
    setState(patient.state ?? '');
    setZipCode(patient.zipCode ?? '');
    setCountry(patient.country ?? '');
    setSex(patient.sex ?? '');
    setSSN(patient.ssn ?? '');
    setDateOfBirth(
      patient.dateOfBirth ? patient.dateOfBirth.slice(0, 10) : ''
    );

    alert('Patient found! Information loaded.');
  } catch (error) {
    setSelectedPatient(null);
    alert(`Could not find patient: ${error.message}`);
  }
}

    async function loadPatients()
    {
      try{
        const result = await api.get('/patients')
        setPatients(result);
      }catch(error)
      {
        alert(`Could not load patients: ${error.message}`);
      }
    }
    useEffect(()=>
    {
      if(section ==='patients')
      {
        loadPatients();
      }

    },[section])
    async function handleLogin()
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
    try
    {
      const account = await api.login(Username, Password)
      setRole(account.role)
      setPage('Dashboard')
    }
    catch (error)
    {
      alert(error.message)
    }
  }
  const handleRecordPayment = ()=>
  {
    if(
        !paymentPatientId ||
        !paymentAmount  ||
        !paymentDate ||
        !paymentMethod ||
        !paymentStatus 
      )
      {
        alert("Please fill in all payment fields")
        return;
      }
      if(Number(paymentAmount)<=0)
      {
        alert("Payment amount must be grater then 0")
        return;
      }
      const payment = {
        patientID: paymentPatientId,
        amount: Number(paymentAmount),
        date: paymentDate,
        method: paymentMethod,
        status: paymentStatus,
      };
      setPayments((previousPayments)=> [
        ...previousPayments,
        payment,
      ]);
      console.log("Payment information:" , payment);
      alert("Payment information calidated check the console");
      setPatientId('');
      setPaymentAmount('');
      setPaymentDate('');
      setPaymentMethod('');
      setPaymentStatus('');
      
  }
   async function handleAddPatient()
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
    if(email ==='' || !email.includes('@'))
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
    
  const patient = {
  SSN: ssn,
  FirstName: firstname,
  MiddleName: middleName || null,
  LastName: lastName,
  StreetAddress: streetAddress,
  ApartmentNum: apartmentNumber || null,
  City: city,
  State: state,
  ZipCode: zipCode,
  Country: country,
  Phone: phone,
  Sex: sex,
  DateOfBirth: dateOfBirth,
  Email: email
};

try {
  const result = await api.post('/patients', patient);

  if (result?.patientID) {
    alert(`Patient created! ID: ${result.patientID}`);
  } else {
    alert('Patient saved successfully!');
  }
} catch (error) {
  alert(`Could not save patient: ${error.message}`);
}

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
          {section === 'reports' && <Reports role={role} />}
          {section === 'appointments' && 
          <Appointments role={role} />}
            <div className="dashboard-nav">
 
  <button onClick={() => setSection('home')}>
    Home
  </button>

 
  {(role === 'Admin' || role === 'Receptionist') && (
    <button onClick={() => setSection('patients')}>
      Patients
    </button>
  )}

 
  {(role === 'Admin' || role === 'Receptionist') && (
    <button onClick={() => setSection('payments')}>
      Payments
    </button>
  )}

  
  {(role === 'Admin' || role === 'Doctor' || role === 'Nurse') && (
    <button onClick={() => setSection('reports')}>
      Reports
    </button>
  )}

  
  {(
    role === 'Admin' ||
    role === 'Doctor' ||
    role === 'Nurse' ||
    role === 'Patient'
  ) && (
    <button onClick={() => setSection('appointments')}>
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
</div>
            {section === 'payments' && (
            <div className='payment-form'>
              <h2>Record Payment</h2>
              <label>Patient ID</label>
              <input 
                type='text'
                placeholder='Enter Patient ID'
                value={paymentPatientId}
                onChange={(e)=>setPatientId(e.target.value)}
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

              <label> Payment methods</label>
                <select 
                   value={paymentMethod}
                onChange={(e)=>setPaymentMethod(e.target.value)}
                >
                  <option value="" disabled>
                    Select Payment Method
                  </option>
                  <option value="cash">Cash</option>
                  <option value="credit">Credit</option>
                  <option value="debit">Debit</option>
                  <option value="insurance">Insurance</option>
                </select>

                <label>Payment Status</label>
                  <select 
                     value={paymentStatus}
                onChange={(e)=>setPaymentStatus(e.target.value)}
                  >
                    <option value="" disabled>
                      Select Status
                    </option>
                    <option value="pending">Pending</option>
                    <option value="paid">Paid</option>
                    <option value="failed">Failed</option>
                  </select>

                  <button type='button' onClick={handleRecordPayment}>
                    Record Payment
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
                          <th>Patient ID</th>
                          <th>Amount</th>
                          <th>Date</th>
                          <th>Method</th>
                          <th>Status</th>
                        </tr>
                      </thead>

                      <tbody>
                        {payments.map((payment,index)=>(
                          <tr key={index}>
                            <td>{payment.patientID}</td>
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


                <button
                  type="button"
                  disabled={!patientToRemove}
                  onClick={handleRemovePatient}
                >
                  Remove Patient
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
