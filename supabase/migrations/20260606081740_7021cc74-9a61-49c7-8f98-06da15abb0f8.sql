UPDATE public.work_schedule SET opd_id = NULL WHERE opd_id IS NOT NULL AND opd_id NOT IN (SELECT id FROM public.opd);
ALTER TABLE public.work_schedule
  ADD CONSTRAINT work_schedule_opd_id_fkey
  FOREIGN KEY (opd_id) REFERENCES public.opd(id) ON DELETE SET NULL;