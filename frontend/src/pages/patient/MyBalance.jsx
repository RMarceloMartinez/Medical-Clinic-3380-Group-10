import { useEffect, useRef, useState } from 'react'
import { api } from '../../api/client'

const money = (value) =>
  Number(value).toLocaleString('en-US', {
    style: 'currency',
    currency: 'USD',
  })

// Display the stored clinic date without shifting it across time zones.
const date = (value) => {
  if (!value) return '—'
  const [year, month, day] = String(value).slice(0, 10).split('-')
  return `${month}/${day}/${year}`
}

// Card numbers end in a check digit (the Luhn formula); this catches typos before submitting
function passesLuhn(digits) {
  let sum = 0
  for (let i = 0; i < digits.length; i++) {
    let d = Number(digits[digits.length - 1 - i])
    if (i % 2 === 1) {
      d *= 2
      if (d > 9) d -= 9
    }
    sum += d
  }
  return sum % 10 === 0
}

export default function MyBalance() {
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')
  const [message, setMessage] = useState('')
  const [selected, setSelected] = useState(null)
  const [amount, setAmount] = useState('')
  const [method, setMethod] = useState('')
  const [cardName, setCardName] = useState('')
  const [cardNumber, setCardNumber] = useState('')
  const [cardExpiry, setCardExpiry] = useState('')
  const [cardCvv, setCardCvv] = useState('')
  const [checkName, setCheckName] = useState('')
  const [checkBank, setCheckBank] = useState('')
  const [checkNumber, setCheckNumber] = useState('')
  const [refreshRequired, setRefreshRequired] = useState(false)
  const [view, setView] = useState('summary')   // 'summary' | 'pay' | 'history'
  const submitting = useRef(false)

  async function loadData() {
    const [balance, charges, history, methods] = await Promise.all([
      api.get('/me/balance'),
      api.get('/me/charges'),
      api.get('/me/payments'),
      api.get('/me/payment-methods'),
    ])
    return { balance, charges, history, methods }
  }

  useEffect(() => {
    let active = true
    loadData()
      .then((result) => {
        if (active) setData(result)
      })
      .catch((e) => {
        if (active) setError(e.message)
      })
      .finally(() => {
        if (active) setLoading(false)
      })
    return () => { active = false }
  }, [])

  async function refresh() {
    setLoading(true)
    setError('')
    setSelected(null)
    try {
      setData(await loadData())
      setRefreshRequired(false)
    } catch (e) {
      setError(e.message)
      setRefreshRequired(true)
    } finally {
      setLoading(false)
    }
  }

  function chooseVisit(visit) {
    setView('pay')
    setSelected(visit)
    setAmount('')
    setMethod('')
    setError('')
    setMessage('')
  }

  async function pay(event) {
    event.preventDefault()
    if (submitting.current || !selected || refreshRequired) return

    const text = amount.trim()
    const value = Number(text)
    if (!/^\d+(\.\d{1,2})?$/.test(text) ||
        !Number.isFinite(value) ||
        value < 0.01 || value > 99999999.99) {
      setError('Enter a valid amount with up to two decimal places.')
      return
    }
    if (value > Number(selected.remaining)) {
      setError(`Enter an amount up to ${money(selected.remaining)}.`)
      return
    }
    if (!data.methods.some((item) => String(item.methodID) === method)) {
      setError('Choose a payment method.')
      return
    }

    if (isCard) {
      const digits = cardNumber.replace(/[ -]/g, '')

      if (!cardName.trim()) {
        setError('Enter the name on the card.')
        return
      }
      if (!/^\d{13,19}$/.test(digits) || !passesLuhn(digits)) {
        setError('Enter a valid card number.')
        return
      }
      const expiry = /^(0[1-9]|1[0-2])\/(\d{2})$/.exec(cardExpiry.trim())
      if (!expiry) {
        setError('Enter the expiration date as MM/YY.')
        return
      }
      // a card is good through the last day of its expiration month
      if (new Date(2000 + Number(expiry[2]), Number(expiry[1]), 1) <= new Date()) {
        setError('This card has expired.')
        return
      }
      if (!/^\d{3,4}$/.test(cardCvv.trim())) {
        setError('Enter the 3- or 4-digit security code (CVV).')
        return
      }
    }

    if (isCheck) {
      if (!checkName.trim() || !checkBank.trim()) {
        setError('Enter the name on the check and the bank name.')
        return
      }
      if (!/^\d{1,10}$/.test(checkNumber.trim())) {
        setError('Enter the check number (1–10 digits).')
        return
      }
    }

    submitting.current = true
    setSaving(true)
    setError('')
    setMessage('')

    try {
      await api.post('/me/payments', {
        appointmentID: selected.appointmentID,
        methodID: Number(method),
        amountApplied: value,
      })
    } catch (e) {
      // Do not automatically retry a payment after an uncertain response.
      setError(`${e.message} Refresh and check payment history before trying again.`)
      setRefreshRequired(true)
      setSelected(null)
      setSaving(false)
      submitting.current = false
      return
    }

    setSelected(null)
    setAmount('')
    setMethod('')
    setMessage(`Payment of ${money(value)} received.`)

    try {
      const updated = await loadData()
      setData(updated)
      const remaining = Number(updated.balance.balance)
      setMessage(
        `Payment of ${money(value)} received. ` +
        (remaining > 0
          ? `You now owe ${money(remaining)}.`
          : remaining < 0
            ? `Your credit balance is ${money(Math.abs(remaining))}.`
            : 'You are all paid up. Thank you!')
      )
    } catch {
      setError('Your payment was received, but the page could not refresh. Refresh to see your updated balance and history.')
      setRefreshRequired(true)
    } finally {
      setSaving(false)
      submitting.current = false
    }
  }

  const disabled = saving || loading || refreshRequired
  const selectedMethod = data?.methods.find(
    (item) => String(item.methodID) === method
  )
  const isCard = ['Credit Card', 'Debit Card'].includes(
    selectedMethod?.methodName
  )
  const isCheck = selectedMethod?.methodName === 'Check'

  const owed = data ? data.charges.filter((visit) => Number(visit.remaining) > 0) : []

  function show(next) {
    setView(next)
    setSelected(null)
    setError('')
    setMessage('')
  }

  return (
    <div className="my-appointments">
      <h2>My balance</h2>

      <div className="page-actions">
        <button type="button" className={view === 'summary' ? 'active' : ''} onClick={() => show('summary')}>
          Summary
        </button>
        <button type="button" className={view === 'pay' ? 'active' : ''} onClick={() => show('pay')}>
          Pay a bill{data ? ` (${owed.length})` : ''}
        </button>
        <button type="button" className={view === 'history' ? 'active' : ''} onClick={() => show('history')}>
          Payment history{data ? ` (${data.history.length})` : ''}
        </button>
        <button type="button" onClick={refresh} disabled={saving || loading}>
          {loading ? 'Loading…' : 'Refresh'}
        </button>
      </div>

      {message && <p className="success-message" role="status">{message}</p>}
      {error && <p className="error-message" role="alert">{error}</p>}

      {data && view === 'summary' && (
        <div className="panel">
          <table className="data-table balance-table">
            <tbody>
              <tr><th>Visits</th><td>{money(data.balance.visits)}</td></tr>
              <tr><th>Late-cancel fees</th><td>{money(data.balance.fees)}</td></tr>
              <tr><th>Paid</th><td>{money(data.balance.paid)}</td></tr>
              <tr className="balance-total">
                <th>{data.balance.balance < 0 ? 'Credit balance' : 'Balance due'}</th>
                <td>{money(Math.abs(data.balance.balance))}</td>
              </tr>
            </tbody>
          </table>
          {Number(data.balance.balance) > 0 ? (
            <div className="page-actions">
              <button type="button" className="primary-button" onClick={() => show('pay')}>
                Pay a bill
              </button>
            </div>
          ) : (
            <p className="field-hint">You are all paid up. Thank you!</p>
          )}
        </div>
      )}

      {data && view === 'pay' && (
        <>
          {owed.length === 0 ? (
            <div className="panel">
              <p>You don't owe anything right now.</p>
            </div>
          ) : (
            <div style={{ overflowX: 'auto' }}>
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Visit date</th><th>Doctor</th><th>Charge type</th>
                    <th>Charged</th><th>Paid</th><th>Owed</th><th></th>
                  </tr>
                </thead>
                <tbody>
                  {owed.map((visit) => (
                    <tr key={visit.appointmentID}>
                      <td>{date(visit.appointmentDateTime)}</td>
                      <td>{visit.doctorName}</td>
                      <td>{visit.status === 'Cancelled' ? 'Late-cancel fee' : 'Visit'}</td>
                      <td>{money(visit.charge)}</td>
                      <td>{money(visit.paid)}</td>
                      <td><strong>{money(visit.remaining)}</strong></td>
                      <td>
                        <button
                          type="button"
                          className="primary-button"
                          disabled={disabled || selected?.appointmentID === visit.appointmentID}
                          onClick={() => chooseVisit(visit)}
                          aria-label={`Pay for the ${date(visit.appointmentDateTime)} visit with ${visit.doctorName}`}
                        >
                          Pay
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}

          {selected && (
            <form className="panel" onSubmit={pay}>
              <h3>Pay for the {date(selected.appointmentDateTime)} visit with {selected.doctorName}</h3>
              <p>Remaining: {money(selected.remaining)}</p>
              <fieldset disabled={saving || loading || refreshRequired}>
                <legend>Payment details</legend>
                <label htmlFor="patient-payment-amount">Amount ($)</label>
                <input
                  id="patient-payment-amount"
                  type="text"
                  inputMode="decimal"
                  value={amount}
                  onChange={(event) => setAmount(event.target.value)}
                  placeholder="50.00"
                  required
                />

                <label htmlFor="patient-payment-method">Payment method</label>
                <select
                  id="patient-payment-method"
                  value={method}
                  onChange={(event) => setMethod(event.target.value)}
                  required
                >
                  <option value="">Choose a method</option>
                  {data.methods.map((item) => (
                    <option key={item.methodID} value={item.methodID}>
                      {item.methodName}
                    </option>
                  ))}
                </select>

                {isCard && (
                  <div className="card-section">
                    <h4>Card information</h4>
                    <p className="field-hint">Card details are only used for this payment and are not saved.</p>

                    <label htmlFor="card-name">Name on card</label>
                    <input
                      id="card-name"
                      type="text"
                      value={cardName}
                      onChange={(e) => setCardName(e.target.value)}
                      placeholder="Name as shown on the card"
                      autoComplete="off"
                      maxLength={60}
                      required
                    />

                    <label htmlFor="card-number">Card number</label>
                    <input
                      id="card-number"
                      type="text"
                      inputMode="numeric"
                      value={cardNumber}
                      onChange={(e) => setCardNumber(e.target.value)}
                      placeholder="1234 5678 9012 3456"
                      autoComplete="off"
                      maxLength={23}
                      required
                    />

                    <label htmlFor="card-expiry">Expiration date (MM/YY)</label>
                    <input
                      id="card-expiry"
                      type="text"
                      value={cardExpiry}
                      onChange={(e) => setCardExpiry(e.target.value)}
                      placeholder="MM/YY"
                      autoComplete="off"
                      maxLength={5}
                      required
                    />

                    <label htmlFor="card-cvv">Security code (CVV)</label>
                    <input
                      id="card-cvv"
                      type="text"
                      inputMode="numeric"
                      value={cardCvv}
                      onChange={(e) => setCardCvv(e.target.value)}
                      placeholder="CVV"
                      autoComplete="off"
                      maxLength={4}
                      required
                    />
                  </div>
                )}

                {isCheck && (
                  <div className="check-section">
                    <h4>Check information</h4>
                    <p className="field-hint">Check details are only used for this payment and are not saved.</p>

                    <label htmlFor="check-name">Name on check</label>
                    <input
                      id="check-name"
                      type="text"
                      value={checkName}
                      onChange={(e) => setCheckName(e.target.value)}
                      placeholder="Name as printed on the check"
                      autoComplete="off"
                      maxLength={60}
                      required
                    />

                    <label htmlFor="check-bank">Bank name</label>
                    <input
                      id="check-bank"
                      type="text"
                      value={checkBank}
                      onChange={(e) => setCheckBank(e.target.value)}
                      placeholder="Bank name"
                      autoComplete="off"
                      maxLength={60}
                      required
                    />

                    <label htmlFor="check-number">Check number</label>
                    <input
                      id="check-number"
                      type="text"
                      inputMode="numeric"
                      value={checkNumber}
                      onChange={(e) => setCheckNumber(e.target.value)}
                      placeholder="1001"
                      autoComplete="off"
                      maxLength={10}
                      required
                    />
                  </div>
                )}

                <button type="submit" className="primary-button">
                  {saving ? 'Processing payment…' : 'Submit payment'}
                </button>
                <button type="button" className="secondary-button" onClick={() => setSelected(null)}>
                  Cancel
                </button>
              </fieldset>
            </form>
          )}

        </>
      )}

      {data && view === 'history' && (
        <>
          {data.history.length === 0 ? (
            <p>No payments recorded yet.</p>
          ) : (
            <div style={{ overflowX: 'auto' }}>
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Paid on</th><th>Visit date</th><th>Doctor</th>
                    <th>Amount</th><th>Method</th><th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  {data.history.map((payment, index) => (
                    <tr key={`${payment.paymentID}-${index}`}>
                      <td>{date(payment.paymentDate)}</td>
                      <td>{date(payment.appointmentDateTime)}</td>
                      <td>{payment.doctorName}</td>
                      <td>{money(payment.amount)}</td>
                      <td>{payment.method}</td>
                      <td>{payment.status}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </>
      )}
    </div>
  )
}
