
from django.urls import path, re_path
from apps.usuario import views 
from django.contrib.auth.decorators import login_required

 
urlpatterns = [
	re_path(r'^$', login_required(views.usuario),name='usuario'), 

	re_path(r'^listar/$',login_required(views.UsuarioList.as_view()),name='listar'),
	re_path(r'^crear/$',login_required(views.UsuarioCreate.as_view()),name='crear'),
	re_path(r'^editar/(?P<pk>\d+)/$',login_required(views.UsuarioUpdate.as_view()),name='editar'),
	re_path(r'^eliminar/(?P<pk>\d+)/$',login_required(views.UsuarioDelete.as_view()),name='eliminar'),



	re_path(r'^u_asmb_lst/$',login_required(views.AsambLst.as_view()),name='u_asmb_lst'),
	re_path(r'^u_asmb_det/?/$',login_required(views.AsambDet.as_view()),name='u_asmb_det'),
	
	re_path(r'^prf_edi/(?P<pk>\d+)/$',login_required(views.PerfilEditar.as_view()),name='prf_edi'),

	re_path(r'^u_orden_lis/$',login_required(views.OrdenList.as_view()),name='u_orden_lis'),

	re_path(r'^u_noticia_lis/$',login_required(views.NoticiaList.as_view()),name='u_noticia_lis'),

	re_path(r'^u_misparcelas_lis/?/$',login_required(views.FiltrarParcelas.as_view()),name='u_misparcelas_lis'),

	re_path(r'^u_reparto_lis/$',login_required(views.VerRepartos.as_view()),name='u_reparto_lis'),

	re_path(r'^u_orden_sol/$',login_required(views.SolOrdenList.as_view()),name='u_orden_sol'),
	re_path(r'^u_orden_eli/(?P<pk>\d+)/$',login_required(views.EliOrden.as_view()),name='u_orden_eli'),

	re_path(r'^u_mis_orden_lis/?/$',login_required(views.MisOrdenes.as_view()),name='u_mis_orden_lis'),

	re_path(r'^pruebas/$',login_required(views.Pruebas),name='pruebas'),


	re_path(r'^api_parc/?/$',login_required(views.ApiTraerParc.as_view()),name='api_parc'),
	re_path(r'^api_ord/?/$',login_required(views.ApiTraerOrd.as_view()),name='api_ord'),
	re_path(r'^api_mul/?/$',login_required(views.ApiTraerMul.as_view()),name='api_mul'),
	re_path(r'^api_perf/?/$',login_required(views.ApiTraerPerf.as_view()),name='api_perf'),
	re_path(r'^api_cont/?/$',login_required(views.ApiContra.as_view()),name='api_cont'),
	re_path(r'^api_edi_sx/?/$',login_required(views.ApiEdiSx.as_view()),name='api_edi_sx'),
	re_path(r'^api_edi_fn/?/$',login_required(views.ApiEdiFn.as_view()),name='api_edi_fn'),
	re_path(r'^api_asmb/?/$',login_required(views.ApiAsamb.as_view()),name='api_asmb'),
	

	re_path(r'^lst_dtjs/?/$',login_required(views.LstDestajos.as_view()),name='lst_dtjs'),
	re_path(r'^mul_lst/?/$',login_required(views.LstMultas.as_view()),name='mul_lst'),


	re_path(r'^api_orden/?/$',login_required(views.ApiOrd.as_view()),name='api_orden'),
	re_path(r'^api_qr/?/$',login_required(views.ApiQr.as_view()),name='api_qr'),

]



#re_path(r'^api_graf1/?/$',login_required(views.ApiGraf1.as_view()),name='api_graf1'),
