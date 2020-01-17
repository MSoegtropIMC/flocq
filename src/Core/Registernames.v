(**
This file is part of the Flocq formalization of floating-point
arithmetic in Coq: http://flocq.gforge.inria.fr/

Copyright (C) 2010-2018 Sylvie Boldo
#<br />#
Copyright (C) 2010-2018 Guillaume Melquiond

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 3 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
COPYING file for more details.
*)

Require Flocq.Core.Core.

(** * Register names for plugins *)

Register Zaux.radix_val as flocq.zaux.radix_val.

Register Raux.bpow as flocq.raux.bpow.
Register Raux.Zfloor as flocq.raux.Zfloor.
Register Raux.Zceil  as flocq.raux.Zceil.
Register Raux.Ztrunc as flocq.raux.Ztrunc.

Register Generic_fmt.round as flocq.generic_fmt.round.
Register Generic_fmt.generic_format as flocq.generic_fmt.generic_format.

Register FLT.FLT_format as flocq.flt.FLT_format.
Register FLT.FLT_exp as flocq.flt.FLT_exp.

Register FLX.FLX_format as flocq.flx.FLX_format.
Register FLX.FLX_exp as flocq.flx.FLX_exp.

Register FIX.FIX_format as flocq.fix.FIX_format.
Register FIX.FIX_exp as flocq.fix.FIX_exp.
