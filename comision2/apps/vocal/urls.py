from django.urls import path, re_path
from apps.vocal import views
from django.contrib.auth.decorators import login_required

urlpatterns = [
    re_path(r'^$', login_required(views.vocal),name='vocal'),
	re_path(r'^v_hasis_gen/?/$',login_required(views.HasisGen.as_view()),name='v_hasis_gen'),



	re_path(r'^v_asamb_reg/$', login_required(views.AsambReg.as_view()),name='v_asamb_reg'),	
	re_path(r'^v_asamb_lis/$', login_required(views.AsambLis.as_view()),name='v_asamb_lis'),
	re_path(r'^v_asamb_edi/?/$',login_required(views.AsambEdi.as_view()),name='v_asamb_edi'),
	re_path(r'^v_asamb_ini/?/$',login_required(views.AsambIni.as_view()),name='v_asamb_ini'),
	re_path(r'^v_hasis_est/?/$',login_required(views.HjaAsisEst.as_view()),name='v_hasis_est'),
	re_path(r'^v_asamb_del/?/$',login_required(views.AsmbDel.as_view()),name='v_asamb_del'),
	re_path(r'^v_asamb_g_rep/?/$',login_required(views.AsmbGrfRep.as_view()),name='v_asamb_g_rep'),

	re_path(r'^v_asamb_p_lst/?/$',login_required(views.AsmbLstPdf.as_view()),name='v_asamb_p_lst'),
	re_path(r'^v_hasis_est/?/$',login_required(views.HjaAsisEst.as_view()),name='v_hasis_est'),
]

