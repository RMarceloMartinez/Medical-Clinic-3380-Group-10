import { useState } from 'react';
import './SearchSelect.css'

export default function SearchSelect({
    id,
    options,
    value,
    onChange,
    placeholder = 'Start typing a patient name...',
    noun = 'patients',
}){
    const [text, setText] = useState('')
    const [open, setOpen] = useState(false)

    const query = text.trim().toLowerCase()
    const matches = options
        .filter((o) => o.name.toLowerCase().includes(query)).slice(0, 8)
    
    function handleType(e){
        setText(e.target.value)
        setOpen(true)
        if(value != null) onChange(null)
    }

    function pick(option){
        setText(option.name)
        setOpen(false)
        onChange(option.id)
    }

    return (
    <div className="ss">
      <input
        id={id}
        type="text"
        autoComplete="off"                     // stops the browser's own suggestions covering ours
        value={text}
        placeholder={placeholder}
        onChange={handleType}
        onFocus={() => setOpen(true)}
        onBlur={() => setOpen(false)}
      />
      {open && query && (
        <ul className="ss-list">
          {matches.length === 0 ? (
            <li className="ss-empty">No {noun} match '{text}'</li>
          ) : (
            matches.map((o) => (
              <li key={o.id}>
                <button
                  type="button"                // inside a <form>, the default type would submit it
                  className="ss-option"
                  onMouseDown={(e) => { e.preventDefault(); pick(o) }}
                >
                  {o.name}
                </button>
              </li>
            ))
          )}
        </ul>
      )}
    </div>
  )

}
