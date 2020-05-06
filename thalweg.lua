-- thalweg (nc02-rs)
-- @artfwo
--
-- E1 volume
-- E2 velocity
-- E3 tempo 
-- K2 shuffle
-- K3 draw

local samples = {
  tonal = {
    path = _path.code .. "nc02-rs/lib/nc02-tonal.wav",
    duration = nil,
    start = nil,
  },
  percussive = {
    path = _path.code .. "nc02-rs/lib/nc02-perc.wav",
    duration = nil,
    start = nil,
  },
  textural = {
    path = _path.code .. "nc02-rs/lib/nc02-zarinskc.wav",
    duration = nil,
    start = nil,
  },
}

local voices = {
  tonal = 1,
  percussive = 2,
  textural = 3,
}

local function load_samples()
  local start = 0

  for key, sample in pairs(samples) do
    local channels, frames, samplerate = audio.file_info(sample.path)
    softcut.buffer_read_mono(sample.path, 0, start, -1, 1, 1)
    
    sample.duration = frames / samplerate
    sample.start = start

    start = start + util.round_up(sample.duration)
  end
end

local function setup_voices()
  for key in pairs(voices) do
    voice = voices[key]
    sample = samples[key]

    softcut.enable(voice, 1)
    softcut.buffer(voice, 1)
    softcut.level(voice, 1)
    softcut.play(voice, 1)
    
    softcut.loop(voice, 0)
    softcut.loop_start(voice, sample.start)
    softcut.loop_end(voice, sample.start + sample.duration)

    softcut.position(voice, sample.start)
    softcut.rate(voice, 1)
    softcut.level_slew_time(voice, 0.5)
    softcut.rate_slew_time(voice, 0.02)
    softcut.level(voice, 0)
  end
  
  softcut.rate(voices.tonal, 2)
  softcut.rate(voices.percussive, 1)
  
  softcut.rate(voices.textural, 1)
  softcut.loop(voices.textural, 1)
  softcut.level(voices.textural, 0.25)
  softcut.level_slew_time(voices.textural, 0.5)
  softcut.rate_slew_time(voices.textural, 0.5)
  softcut.fade_time(voices.textural, 0)

  softcut.post_filter_fc(voices.textural, 550)
  softcut.post_filter_lp(voices.textural, 1)
  softcut.post_filter_dry(voices.textural, 0.5)
  
  softcut.post_filter_fc(voices.percussive, 7550)
  softcut.post_filter_lp(voices.percussive, 1)
  softcut.post_filter_dry(voices.percussive, 0.5)
  
end

local function move_tonal()
  while true do
    for i=1,4 do
      clock.sync(3/4 * i)
      softcut.position(voices.tonal, samples.tonal.start + ((i - 1) % 3) * 0.5)
      softcut.level(voices.tonal, 1)
      clock.sync(1/4)
      softcut.level(voices.tonal, 0)
      clock.sync(1/4 * i)
    end
  end
end

local function move_percussive()
  while true do
    for i=1,4 do
      clock.sync(1/7)
      softcut.level(voices.percussive, 0.3)
      softcut.position(voices.percussive, samples.percussive.start + ((i - 1) % 3) * 1)
      clock.sync(1/16)
      softcut.level(voices.percussive, 0)
      clock.sync(3/7)
    end
  end
end

local function move_textural()
  while true do
    for i=1,4 do
      clock.sync(1)
      softcut.level(voices.textural, 0.15)
      softcut.position(voices.percussive, samples.percussive.start + ((i - 1) % 3) * 1)
      clock.sync(1/4)
      softcut.level(voices.textural, 0.15)
    end
  end
end

local function phase(voice, phase)
end

function init()
  softcut.reset()

  load_samples()
  setup_voices()

  softcut.event_phase(phase)
  softcut.poll_start_phase() 

  clock.run(move_tonal)
  clock.run(move_percussive)
  clock.run(move_textural)
end

function enc(n, d)
  if n == 1 then
    mix:delta("output", d)
  end
end

function key(n, z)
end

function redraw()
  screen.clear()
  screen.move(64, 50)
  screen.aa(1)
  screen.font_face(4)
  screen.font_size(50)
  screen.text_center("0")
  screen.update()
end
