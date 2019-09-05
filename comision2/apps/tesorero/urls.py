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
]
 