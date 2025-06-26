<template>
  <div class="hangman-app">
    <main class="game-container">
      <section class="hangman-drawing-section">
        <!-- Hangman Drawing -->
        <HangmanDrawing :wrongGuesses="wrongGuesses.length" />
      </section>

      <section class="game-section">
        <header class="word-display">
          <WordDisplay
            :word="gameWord"
            :guessedLetters="guessedLetters"
            :status="gameStatus"
          />
        </header>

        <LetterInput
          :disabled="isInputDisabled"
          :usedLetters="guessedLetters"
          @guess="handleGuess"
        />

        <div class="used-letters-area">
          <span class="section-label">Wrong Letters:</span>
          <div class="used-letters">
            <UsedLetters :letters="wrongGuesses" />
          </div>
        </div>

        <footer class="game-status">
          <StatusMessage :status="gameStatus" :word="gameWord" />
          <button
            class="new-game-button"
            :class="{ shake: gameStatus !== 'playing' }"
            @click="startNewGame"
          >
            New Game
          </button>
        </footer>
      </section>
    </main>
  </div>
</template>

<script setup lang="ts">
// Color palette
const COLORS = {
  accent: '#F59E42',
  primary: '#4F46E5',
  secondary: '#D946EF'
}

import { ref, computed } from 'vue'

// --- Game Logic ---
// PUBLIC_INTERFACE
const WORD_LIST = [
  'NUXT', 'COMPUTER', 'VUE', 'JAVASCRIPT',
  'PROGRAMMING', 'HANGMAN', 'MINIMAL', 'THEME', 'PALLETE', 'RESPONSIVE'
]

type GameStatus = 'playing' | 'won' | 'lost'

const gameWord = ref('')
const guessedLetters = ref<string[]>([])
const wrongGuesses = ref<string[]>([])
const gameStatus = ref<GameStatus>('playing')

function pickRandomWord() {
  const idx = Math.floor(Math.random() * WORD_LIST.length)
  return WORD_LIST[idx]
}

// PUBLIC_INTERFACE
function startNewGame() {
  gameWord.value = pickRandomWord()
  guessedLetters.value = []
  wrongGuesses.value = []
  gameStatus.value = 'playing'
}

function normalizeInput(ltr: string) {
  return ltr.trim().toUpperCase().slice(0, 1)
}

// PUBLIC_INTERFACE
function handleGuess(letter: string) {
  if (gameStatus.value !== 'playing' || !letter.match(/[A-Z]/)) return

  const ltr = normalizeInput(letter)
  if (guessedLetters.value.includes(ltr)) return // ignore already-used

  guessedLetters.value.push(ltr)
  if (gameWord.value.includes(ltr)) {
    // Check win
    const wordLetters = [...new Set(gameWord.value.split(''))] // Unique letters
    const allGuessed = wordLetters.every((w) => guessedLetters.value.includes(w))
    if (allGuessed) gameStatus.value = 'won'
  } else {
    // Add incorrect guesses to wrongGuesses, update gameStatus if lost condition met
    wrongGuesses.value = [...wrongGuesses.value, ltr]
    if (wrongGuesses.value.length >= 6) {
      gameStatus.value = 'lost'
    }
  }
}

const isInputDisabled = computed(() => gameStatus.value !== 'playing')

// On mount, start a game
if (process.client) startNewGame();
</script>

<style scoped>
.hangman-app {
  min-height: 100vh;
  min-width: 100vw;
  box-sizing: border-box;
  background: #f8f9fa;
  font-family: 'Inter', 'Segoe UI', 'Helvetica Neue', Arial, sans-serif;
  display: flex;
  align-items: center;
  justify-content: center;
}
.game-container {
  background: white;
  border-radius: 1.5rem;
  box-shadow: 0 5px 24px 0 rgba(60,60,60,0.08);
  display: flex;
  flex-direction: row;
  padding: 2rem 2rem 1.5rem 2rem;
  gap: 3rem;
  max-width: 750px;
  width: 100%;
  align-items: stretch;
  justify-content: center;
}
.hangman-drawing-section {
  min-width: 170px;
  margin-top: 0.5rem;
  display: flex;
  align-items: flex-start;
  justify-content: center;
}
.game-section {
  flex: 1 1 0px;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  min-width: 250px;
}
.word-display {
  font-size: 2rem;
  margin: 0 0 1.3rem 0;
  letter-spacing: 1.2px;
  font-weight: 600;
  text-align: center;
  color: #333;
  min-height: 2.4em;
}

.used-letters-area {
  margin: 1.3rem auto 0.2rem auto;
  letter-spacing: 1px;
  font-size: 1.02rem;
  text-align: center;
}
.section-label {
  color: #aaa;
  font-size: 0.98rem;
  padding-right: 0.5em;
}
.used-letters {
  font-size: 1.1em;
  color: #bf2930;
  letter-spacing: 2.5px;
  font-weight: 500;
  display: inline-block;
  min-height: 1.4em;
  margin-left: 0.3em;
}
.game-status {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-top: 1.3rem;
  min-height: 3em;
}
.new-game-button {
  margin-top: 0.65em;
  padding: 0.75em 1.7em;
  font-size: 1.1em;
  border: none;
  border-radius: .3em;
  background: linear-gradient(90deg, #4F46E5 60%, #D946EF 100%);
  color: #fff;
  letter-spacing: 0.5px;
  font-weight: 600;
  cursor: pointer;
  box-shadow: 0 2px 12px 0 rgba(79,70,229,0.06);
  transition: background 0.23s, transform 0.09s;
}
.new-game-button:active {
  background: linear-gradient(90deg, #F59E42 70%, #D946EF 100%);
  transform: translateY(1px) scale(0.98);
}
.new-game-button.shake {
  animation: shake 0.25s linear 2;
}
@keyframes shake {
  0% { transform: translateX(0); }
  25% { transform: translateX(-3px); }
  50% { transform: translateX(3px); }
  75% { transform: translateX(-2px); }
  100% { transform: translateX(0); }
}

@media (max-width: 700px) {
  .game-container {
    flex-direction: column;
    gap: 0.7rem;
    padding: 1.1rem 0.5rem 1rem 0.5rem;
    max-width: 97vw;
  }
  .hangman-drawing-section {
    margin: 0 auto 0.3rem auto;
    min-width: 110px;
  }
}
</style>

<!-- Subcomponents Inline (for this contained task) -->
<script lang="ts">
// PUBLIC_INTERFACE
import { defineComponent, ref, watch, computed } from 'vue'

const HangmanDrawing = defineComponent({
  name: 'HangmanDrawing',
  props: {
    wrongGuesses: { type: Number, required: true }
  },
  setup(props) {
    // Each part is revealed step by step
    const partsToDraw = [
      // [ x1, y1, x2, y2, lineWidth, strokeStyle ]
      // base, pole, beam, rope
      (ctx: CanvasRenderingContext2D) => { ctx.lineWidth=7; ctx.strokeStyle='#222'; ctx.beginPath(); ctx.moveTo(25,145); ctx.lineTo(130,145); ctx.stroke(); },
      (ctx: CanvasRenderingContext2D) => { ctx.lineWidth=6; ctx.strokeStyle='#ccc'; ctx.beginPath(); ctx.moveTo(45,22); ctx.lineTo(45,145); ctx.stroke(); }, 
      (ctx: CanvasRenderingContext2D) => { ctx.lineWidth=5.5; ctx.strokeStyle=COLORS.primary; ctx.beginPath(); ctx.moveTo(42,22); ctx.lineTo(105,22); ctx.stroke(); },
      (ctx: CanvasRenderingContext2D) => { ctx.lineWidth=4.5; ctx.strokeStyle=COLORS.accent; ctx.beginPath(); ctx.moveTo(104,22);ctx.lineTo(104,43);ctx.stroke(); },
      // head
      (ctx: CanvasRenderingContext2D) => { ctx.lineWidth=3.5; ctx.strokeStyle=COLORS.secondary; ctx.beginPath(); ctx.arc(104,54,11,0,2*Math.PI); ctx.stroke(); },
      // body
      (ctx: CanvasRenderingContext2D) => { ctx.lineWidth=4; ctx.strokeStyle='#444'; ctx.beginPath(); ctx.moveTo(104,65); ctx.lineTo(104,110); ctx.stroke(); },
      // left arm
      (ctx: CanvasRenderingContext2D) => { ctx.lineWidth=3.3; ctx.strokeStyle='#888'; ctx.beginPath(); ctx.moveTo(104,74); ctx.lineTo(85,98); ctx.stroke(); },
      // right arm
      (ctx: CanvasRenderingContext2D) => { ctx.lineWidth=3.3; ctx.strokeStyle='#888'; ctx.beginPath(); ctx.moveTo(104,74); ctx.lineTo(124,98); ctx.stroke(); },
      // left leg
      (ctx: CanvasRenderingContext2D) => { ctx.lineWidth=3.2; ctx.strokeStyle='#b8712b'; ctx.beginPath(); ctx.moveTo(104,110); ctx.lineTo(88,134); ctx.stroke(); },
      // right leg
      (ctx: CanvasRenderingContext2D) => { ctx.lineWidth=3.2; ctx.strokeStyle='#b8712b'; ctx.beginPath(); ctx.moveTo(104,110); ctx.lineTo(120,134); ctx.stroke(); }
    ];

    const canvas = ref<HTMLCanvasElement | null>(null)
    watch(() => props.wrongGuesses, (val) => draw(), { immediate: true })

    function draw() {
      const c = canvas.value
      if (!c) return
      const ctx = c.getContext('2d')
      if (!ctx) return
      ctx.clearRect(0, 0, c.width, c.height)
      // Always show base/pole/beam/rope, then add for each wrong
      for (let i=0; i < partsToDraw.length; ++i) {
        if (i < 4 || (i-3) <= props.wrongGuesses) partsToDraw[i](ctx)
        if (i-3 === props.wrongGuesses && i > 3) break
      }
    }
    return () => (
      <canvas
        ref={canvas}
        width="160"
        height="155"
        style="background:transparent;display:block;margin:0 auto;"
        aria-label="Hangman drawing"
      />
    )
  }
})

// PUBLIC_INTERFACE
const WordDisplay = defineComponent({
  name: 'WordDisplay',
  props: {
    word: { type: String, required: true },
    guessedLetters: { type: Array as () => string[], required: true },
    status: { type: String as () => GameStatus, required: true }
  },
  setup(props) {
    const wordChars = computed(() => props.word.split(''))
    return () => (
      <span style="letter-spacing:0.58em;">
        {wordChars.value.map((chr, idx) =>
          chr === ' ' ?
            <span key={idx} style="margin-right:0.4em;">&nbsp;</span> :
            <span key={idx} class="word-letter" style={`
              border-bottom: 2.5px solid ${COLORS.primary};
              margin: 0 0.12em; padding: 0 0.17em; min-width: 0.9em; display: inline-block;
              color: ${props.guessedLetters.includes(chr) || props.status === 'lost' ? '#1d203c' : '#bbb'};
              font-weight:${props.guessedLetters.includes(chr) || props.status === 'lost' ? 700 : 400};
              background: ${props.guessedLetters.includes(chr) ? COLORS.secondary + '22' : 'transparent'}; 
              border-radius: 0.22em;
              text-shadow: 0 1px 0 #fff;
            `}>
              {props.guessedLetters.includes(chr) || props.status === 'lost' ? chr : ''}
            </span>
        )}
      </span>
    )
  }
})

// PUBLIC_INTERFACE
const UsedLetters = defineComponent({
  name: 'UsedLetters',
  props: { letters: { type: Array as () => string[], required: true }},
  setup(props) {
    return () => (
      <>
        {props.letters.map(l => l + ' ').join('')}
      </>
    )
  }
})

// PUBLIC_INTERFACE
const StatusMessage = defineComponent({
  name: 'StatusMessage',
  props: {
    status: { type: String as () => GameStatus, required: true },
    word: { type: String, required: true }
  },
  setup(props) {
    function capWord(word: string) {
      if (!word) return ''
      return word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()
    }
    return () => {
      if (props.status === 'won') {
        return <div class="status-message" style={`
          color:${COLORS.primary};
          font-weight:650;
          font-size:1.18em;
          margin-bottom:0.5em;`}>
          🎉 You won! The word was <span style="color:${COLORS.secondary}">{capWord(props.word)}</span>
        </div>
      }
      if (props.status === 'lost') {
        return <div class="status-message" style={`
          color:#b71c1c;
          font-weight:550;
          font-size:1.12em;
          margin-bottom:0.45em;`}>
          Game over! The word was <span style="color:${COLORS.primary}">{capWord(props.word)}</span>
        </div>
      }
      return null
    }
  }
})

// PUBLIC_INTERFACE
const LetterInput = defineComponent({
  name: 'LetterInput',
  props: {
    disabled: { type: Boolean, default: false },
    usedLetters: { type: Array as () => string[], required: true }
  },
  emits: ['guess'],
  setup(props, { emit }) {
    const input = ref('')

    function guessLetter() {
      const ltr = input.value.trim().toUpperCase().slice(0,1)
      if (!ltr.match(/^[A-Z]$/) || props.usedLetters.includes(ltr)) {
        input.value = ''
        return
      }
      emit('guess', ltr)
      input.value = ''
    }

    function onKeydown(e: KeyboardEvent) {
      if (props.disabled) return
      if (e.key === 'Enter') {
        guessLetter()
        e.preventDefault()
      }
    }

    // Keyboard: auto focus, handle single key typing
    const inputEl = ref<HTMLInputElement|null>(null)
    watch(() => props.disabled, d => {
      if (!d && inputEl.value) inputEl.value.focus()
    })

    return () => (
      <form
        class="letter-input-form"
        style={`
          margin: 0 auto;
          display: flex;
          flex-direction: row;
          justify-content: center;
          gap: 1em;
          align-items: center;
          margin-bottom: 0.4em;
        `}
        onSubmit={e => { e.preventDefault(); guessLetter(); }}
        >
        <input
          ref={inputEl}
          aria-label="Guess a letter"
          class="guess-input"
          type="text"
          maxlength="1"
          minlength="1"
          autocomplete="off"
          spellcheck="false"
          :disabled="props.disabled"
          style={`
            width: 3em;
            font-size: 1.5em;
            text-align: center;
            border: 2px solid ${COLORS.primary};
            border-radius: 0.26em;
            padding: 0.31em;
            margin-right: 0.6em;
            background: #fff;
            color: #333;
            outline: none;
            transition: border-color 0.19s;
          `}
          v-model={input.value}
          onInput={(e: any) => { input.value = e.target.value.replace(/[^a-zA-Z]/g, '').toUpperCase().slice(0,1) }}
          onKeydown={onKeydown}
        />
        <button
          type="submit"
          class="guess-button"
          style={`
            background: ${COLORS.accent};
            border: none;
            color: #fff;
            font-weight: 600;
            font-size: 1.07em;
            border-radius: 0.22em;
            padding: 0.53em 1em;
            cursor: pointer;
            box-shadow: 0 2px 9px 0 rgba(245,158,66,0.05);
            transition: background 0.17s;
          `}
          :disabled="props.disabled"
        >
          Guess
        </button>
      </form>
    )
  }
})
</script>
