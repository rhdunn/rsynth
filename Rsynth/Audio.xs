/*
  Copyright (c) 1996, 2001 Nick Ing-Simmons. All rights reserved.
  This program is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.
*/
#define PERL_NO_GET_CONTEXT

#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>
#include "Audio.m"

AudioVtab *AudioVptr;

#include "rsynth.h"
#include "english.h"

lang_t *lang = &English;

static void *
Rsynth_sample(void *user_data,float sample,unsigned nsamp, rsynth_t *rsynth)
{
 dTHX;
 Audio *au = (Audio *) user_data;
 float *p  = Audio_more(aTHX_ au,1);
 /* FIXME - avoid this divide my adjusting gain on create */
 *p = sample/32768;
 return user_data;
}

MODULE = Rsynth::Audio	PACKAGE = Rsynth::Audio PREFIX = rsynth_

PROTOTYPES: ENABLE

rsynth_t *
rsynth_new(char *Class, Audio *au, float F0Hz = 133.3, float ms_per_frame = 10.0, long gain = 57)
CODE:
 {
  speaker_t *speaker = rsynth_speaker(F0Hz, gain, Elements);
  RETVAL = rsynth_init(au->rate,ms_per_frame, speaker,Rsynth_sample,0,au);
 }
OUTPUT:
 RETVAL

void 
rsynth_pho(rsynth_t *rsynth, char *file, int dodur = 1, char *phones = "sampa")

void
rsynth_phones(rsynth_t *rsynth, char *s, int len = strlen(s))

void
say_string(rsynth_t *rsynth, char *s)

void
rsynth_term(rsynth_t *rsynth)

BOOT:
 {
  AudioVptr = (AudioVtab *) SvIV(perl_get_sv("Audio::Data::AudioVtab",0));
 }
