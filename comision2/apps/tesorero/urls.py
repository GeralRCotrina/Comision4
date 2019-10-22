from django.urls import path, re_path
from apps.tesorero import views
from django.contrib.auth.decorators import login_required

urlpatterns = [
	re_path(r'^$', login_required(views.tesorero),name='tesorero'),
	re_path(r'^t_asmb/$',login_required(views.Asmb.as_view()),name='t_asmb'),
	re_path(r'^t_asmb_mul/(?P<pk>\d+)/$',login_required(views.AsmbMul.as_view()),name='t_asmb_mul'),

	re_path(r'^t_mul_todas/?/$',login_required(views.MultarAsistenciaTodas.as_view()),name='t_mul_todas'),
	re_path(r'^t_mul/?/$',login_required(views.MultarAsistencia.as_view()),name='t_mul'),
	re_path(r'^t_h_mul/?/$',login_required(views.VerHojaDeMultas.as_view()),name='t_h_mul'),

	re_path(r'^t_edi_mul/?/$',login_required(views.EditarMulta.as_view()),name='t_edi_mul'),
	re_path(r'^t_eli_mul/?/$',login_required(views.EliminarMulta.as_view()),name='t_eli_mul'),
	re_path(r'^t_mul_imp/?/$',login_required(views.ImprimirMulta.as_view()),name='t_mul_imp'),
	re_path(r'^t_std_mul/?/$',login_required(views.EstdoMulta.as_view()),name='t_std_mul'),

	re_path(r'^t_edi_mulo/?/$',login_required(views.EditarMultaO.as_view()),name='t_edi_mulo'),
	re_path(r'^t_eli_mulo/?/$',login_required(views.EliminarMultaO.as_view()),name='t_eli_mulo'),
	re_path(r'^t_std_mulo/?/$',login_required(views.EstdoMultaO.as_view()),name='t_std_mulo'),
	re_path(r'^t_mul_impo/?/$',login_required(views.ImprimirMultaO.as_view()),name='t_mul_impo'),


	re_path(r'^t_lst_repartos/?/$',login_required(views.LstRepartos.as_view()),name='t_lst_repartos'),
	re_path(r'^hj_ml_reparto/?/$',login_required(views.HjaMulReparto.as_view()),name='hj_ml_reparto'),
	re_path(r'^hj_or_reparto/?/$',login_required(views.HjaOrdReparto.as_view()),name='hj_or_reparto'),

	re_path(r'^mul_or/?/$',login_required(views.MultaOrden.as_view()),name='mul_or'),
	re_path(r'^t_ord_std/?/$',login_required(views.EstadoOrden.as_view()),name='t_ord_std'),


	re_path(r'^t_comp_gen/?/$',login_required(views.CompGenerar.as_view()),name='t_comp_gen'),
	re_path(r'^t_cmp_lst/?/$',login_required(views.CompListarOrd.as_view()),name='t_cmp_lst'),



	re_path(r'^t_lst_lmps/?/$',login_required(views.LstLimpiezas.as_view()),name='t_lst_lmps'),
	re_path(r'^t_lst_dstjs/?/$',login_required(views.LstDestajos.as_view()),name='t_lst_dstjs'),
	re_path(r'^mul_dest_cre/?/$',login_required(views.CrearMulDstj.as_view()),name='mul_dest_cre'),

	re_path(r'^lst_muls_lmp/?/$',login_required(views.LstMulsLimpia.as_view()),name='lst_muls_lmp'),
 
	re_path(r'^t_std_muld/?/$',login_required(views.EstdoMultaD.as_view()),name='t_std_muld'),
	re_path(r'^t_eli_muld/?/$',login_required(views.EliminarMultaD.as_view()),name='t_eli_muld'),
	re_path(r'^t_edi_muld/?/$',login_required(views.EditarMultaD.as_view()),name='t_edi_muld'),
	re_path(r'^t_mul_impd/?/$',login_required(views.ImprimirMultaD.as_view()),name='t_mul_impd'),



	re_path(r'^t_rep/$',login_required(views.Reportes.as_view()),name='t_rep'),



	

]
 