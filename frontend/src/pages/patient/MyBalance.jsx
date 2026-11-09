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
  const [refreshRequired, setRefreshRequired] = useState(false)
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
      const digits = cardNumber.replace(/ /g, '')

      if (!cardName.trim()) {
        setError('Enter a fictional cardholder name.')
        return
      }
      if (digits !== '4242424242424242') {
        setError('Use the demo test card number: 4242 4242 4242 4242.')
        return
      }
      if (cardExpiry !== '12/30') {
        setError('Use the demo expiration date: 12/30.')
        return
      }
      if (cardCvv !== '123') {
        setError('Use the demo security code: 123.')
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
    setMessage(`Payment of ${money(value)} saved.`)

    try {
      const updated = await loadData()
      setData(updated)
      const remaining = Number(updated.balance.balance)
      setMessage(
        `Payment of ${money(value)} saved. ` +
        (remaining > 0
          ? `You now owe ${money(remaining)}.`
          : remaining < 0
            ? `Your credit balance is ${money(Math.abs(remaining))}.`
            : 'You are all paid up. Thank you!')
      )
    } catch {
      setError('Your payment was saved, but the page could not refresh. Refresh to see your updated balance and history.')
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

  return (
    <div className="panel">
      <h2>My balance</h2>

      {message && <p className="success-message" role="status">{message}</p>}
      {error && <p className="error-message" role="alert">{error}</p>}

      <button type="button" onClick={refresh} disabled={saving || loading}>
        {loading ? 'Loading…' : 'Refresh'}
      </button>

      {data && (
        <>
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

          <h3>Visit balances</h3>
          {data.charges.length === 0 ? (
            <p>No billed visits or cancellation fees yet.</p>
          ) : (
            <div style={{ overflowX: 'auto' }}>
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Visit</th><th>Date</th><th>Charge type</th>
                    <th>Charged</th><th>Paid</th><th>Remaining</th><th>Action</th>
                  </tr>
                </thead>
                <tbody>
                  {data.charges.map((visit) => (
                    <tr key={visit.appointmentID}>
                      <td>{visit.appointmentID}</td>
                      <td>{date(visit.appointmentDateTime)}</td>
                      <td>{visit.status === 'Cancelled' ? 'Late-cancel fee' : 'Visit'}</td>
                      <td>{money(visit.charge)}</td>
                      <td>{money(visit.paid)}</td>
                      <td>{money(visit.remaining)}</td>
                      <td>
                        {Number(visit.remaining) > 0 ? (
                          <button
                            type="button"
                            disabled={disabled}
                            onClick={() => chooseVisit(visit)}
                            aria-label={`Pay for visit ${visit.appointmentID}`}
                          >
                            Pay
                          </button>
                        ) : 'Paid'}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}

          {selected && (
            <form onSubmit={pay}>
              <h3>Pay for visit {selected.appointmentID}</h3>
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
                  <div className="demo-card-section">
                    <h4>Demo card information</h4>
                    <p>
                      Demo only — enter fictional test information.
                      Do not enter real card details. No card details are
                      transmitted or stored.
                    </p>

                    <label htmlFor="demo-card-name">Cardholder name</label>
                    <input
                      id="demo-card-name"
                      type="text"
                      value={cardName}
                      onChange={(e) => setCardName(e.target.value)}
                      placeholder="DEMO PATIENT"
                      autoComplete="off"
                      maxLength={60}
                      required
                    />

                    <label htmlFor="demo-card-number">Test card number</label>
                    <input
                      id="demo-card-number"
                      type="text"
                      inputMode="numeric"
                      value={cardNumber}
                      onChange={(e) => setCardNumber(e.target.value)}
                      placeholder="4242 4242 4242 4242"
                      autoComplete="off"
                      maxLength={19}
                      required
                    />

                    <label htmlFor="demo-card-expiry">Expiration date</label>
                    <input
                      id="demo-card-expiry"
                      type="text"
                      value={cardExpiry}
                      onChange={(e) => setCardExpiry(e.target.value)}
                      placeholder="12/30"
                      autoComplete="off"
                      maxLength={5}
                      required
                    />

                    <label htmlFor="demo-card-cvv">Demo security code</label>
                    <input
                      id="demo-card-cvv"
                      type="text"
                      inputMode="numeric"
                      value={cardCvv}
                      onChange={(e) => setCardCvv(e.target.value)}
                      placeholder="123"
                      autoComplete="off"
                      maxLength={3}
                      required
                    />
                  </div>
                )}

                <button type="submit">
                  {saving ? 'Saving…' : 'Save payment'}
                </button>
                <button type="button" onClick={() => setSelected(null)}>
                  Cancel
                </button>
              </fieldset>
            </form>
          )}

          <h3>Payment history</h3>
          {data.history.length === 0 ? (
            <p>No payments recorded yet.</p>
          ) : (
            <div style={{ overflowX: 'auto' }}>
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Payment</th><th>Payment date</th><th>Visit</th>
                    <th>Visit date</th><th>Amount</th><th>Method</th><th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  {data.history.map((payment, index) => (
                    <tr key={`${payment.paymentID}-${index}`}>
                      <td>{payment.paymentID}</td>
                      <td>{date(payment.paymentDate)}</td>
                      <td>{payment.appointmentID}</td>
                      <td>{date(payment.appointmentDateTime)}</td>
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
