;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                                                                       ;;
;;;                       Nicholas Ing-Simmons                            ;;
;;;                        Copyright (c) 2002                             ;;
;;;                        All Rights Reserved.                           ;;
;;;                                                                       ;;
;;;  Permission is hereby granted, free of charge, to use and distribute  ;;
;;;  this software and its documentation without restriction, including   ;;
;;;  without limitation the rights to use, copy, modify, merge, publish,  ;;
;;;  distribute, sublicense, and/or sell copies of this work, and to      ;;
;;;  permit persons to whom this work is furnished to do so, subject to   ;;
;;;  the following conditions:                                            ;;
;;;   1. The code must retain the above copyright notice, this list of    ;;
;;;      conditions and the following disclaimer.                         ;;
;;;   2. Any modifications must be clearly marked as such.                ;;
;;;   3. Original authors' names are not deleted.                         ;;
;;;   4. The authors' names are not used to endorse or promote products   ;;
;;;      derived from this software without specific prior written        ;;
;;;      permission.                                                      ;;
;;;                                                                       ;;
;;;  THE UNIVERSITY OF EDINBURGH AND THE CONTRIBUTORS TO THIS WORK        ;;
;;;  DISCLAIM ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING      ;;
;;;  ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT   ;;
;;;  SHALL THE UNIVERSITY OF EDINBURGH NOR THE CONTRIBUTORS BE LIABLE     ;;
;;;  FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES    ;;
;;;  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN   ;;
;;;  AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,          ;;
;;;  ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF       ;;
;;;  THIS SOFTWARE.                                                       ;;
;;;                                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  A british mail voice using rsynth formant synthesis
;;;  This uses the standard Roger top end and executes the external
;;;  rsynth program to form the waveform.
;;;
;;;  Note this requires rsynth which has its own licence different
;;;  from the one above
;;;
;;;  To install
;;;  1) put the rsynth executable in festival/lib/etc/[OSTYPE]/
;;;     where [OSTYPE] is the os type of your installation, there
;;;     will already be a directory of the appropriate name in
;;;     festival/lib/etc/ after you have installed festival (if there
;;;     isn't just add rsynth to festival/lib/etc/ instead)
;;;     The directory you put it in should also contain audsp (the
;;;     the audio spooler) as that directory is already in Festival's
;;;     path.
;;;
;;;  call (voice_rsynth_br_m) in festival to select the voice or
;;;  add to siteinit.scm 
;;;     (set! voice_default 'voice_rsynth_br_m)
;;;  to make it always select this voice as the default

(set! rsynth_br_m_dir (cdr (assoc 'rsynth_br_m voice-locations)))

(require 'mrpa_phones)
(require 'pos)
(require 'phrase)
(require 'tobi)
(require 'f2bf0lr)
(require 'mrpa_durs)
(require 'gswdurtreeZ)
(require 'rsynth)

(setup_oald_lex)

(define (rsynth_postlex_syllabics utt)
"(rsynth_postlex_syllabics utt)
Becuase the lexicon is somewhat random in its used of syllable l n and
m this is designed to post process the output inserting schwa before
them.  Ideally the lexicon should be fixed."
  (mapcar
   (lambda (s)
     (if (and (member_string (item.name s) '("l" "n" "m"))
	      (string-equal "coda" (item.feat s "seg_onsetcoda"))
	      ;; r wont exist for British English so this is OK
	      (string-equal "-" (item.feat s "p.ph_vc")))
	 ;; Insert a schwa in the Segment and SylStructure relations
	 (item.relation.insert 
	  s 'SylStructure
	  (item.insert s (list "@") 'before)
	  'before)))
   (utt.relation.items utt 'Segment)))

(define (voice_rsynth_br_m)
"(voice_rsynth_br_m)
 Set up the current voice to be a British male RP speaker using
 rsynth."
  (voice_reset)
  (Parameter.set 'Language 'britishenglish)
  ;; Phone set
  (Parameter.set 'PhoneSet 'mrpa)
  (PhoneSet.select 'mrpa)
  ;; Tokenization rules
  (set! token_to_words english_token_to_words)
  ;; POS tagger
  (set! pos_lex_name "english_poslex")
  (set! pos_ngram_name 'english_pos_ngram)
  (set! pos_supported t)
  (set! guess_pos english_guess_pos)   ;; need this for accents
  ;; Lexicon selection
  (lex.select "oald")
  (set! postlex_rules_hooks (list postlex_apos_s_check
				  rsynth_postlex_syllabics))
  ;; Phrase prediction
  (Parameter.set 'Phrase_Method 'prob_models)
  (set! phr_break_params english_phr_break_params)
  ;; Accent and tone prediction
  (set! int_tone_cart_tree f2b_int_tone_cart_tree)
  (set! int_accent_cart_tree f2b_int_accent_cart_tree)
  ;; F0 prediction
  (set! f0_lr_start f2b_f0_lr_start)
  (set! f0_lr_mid f2b_f0_lr_mid)
  (set! f0_lr_end f2b_f0_lr_end)
  (Parameter.set 'Int_Method Intonation_Tree)
  (set! int_lr_params
	'((target_f0_mean 110) (target_f0_std 15)
	  (model_f0_mean 170) (model_f0_std 34)))
  (Parameter.set 'Int_Target_Method Int_Targets_LR)
  ;; Duration prediction -- use gsw durations
  (set! duration_cart_tree gsw_duration_cart_tree)
  (set! duration_ph_info gsw_durs)
  (Parameter.set 'Duration_Method Duration_Tree_ZScores)
  (Parameter.set 'Duration_Stretch 0.95)
  ;; Waveform synthesizer: rsynth 
  (Parameter.set 'Synth_Method rsynth_Synth)
  ;;  Because we need an extra parameter in the new version of rsynth
  ;;  we add that parameter to the database "name"
  (set! rsynth_progname "/home/p4work/rsynth/rsynth")
  (set! rsynth_options 
	(format 
	 nil
	 "-a -I %s%s"
         rsynth_br_m_dir "mrpa-sampa"
	 ))
  (set! current-voice 'rsynth_br_m)
)

(proclaim_voice
 'rsynth_br_m
 '((language english)
   (gender male)
   (dialect british)
   (description
    "This voice provides a British RP English male voice using the
     rsynth synthesis method.  It uses a 
     modified Oxford Advanced Learners' Dictionary for pronunciations.
     Prosodic phrasing is provided by a statistically trained model
     using part of speech and local distribution of breaks.  Intonation
     is provided by a CART tree predicting ToBI accents and an F0 
     contour generated from a model trained from natural speech.  The
     duration model is also trained from data using a CART tree.")))

(provide 'rsynth_br_m)

