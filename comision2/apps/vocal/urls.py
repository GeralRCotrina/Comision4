from django.urls import path, re_path
from apps.vocal import views
from django.contrib.auth.decorators import login_required

urlpatterns = [
    re_path(r'^$', login_required(views.vocal),name='vocal'),
	re_path(r'^v_asmb_lis/',login_required(views.AsmbList.as_view()),name='v_asmb_lis'),
	re_path(r'^v_hasis_gen/?/$',login_required(views.HasisGen.as_view()),name='v_hasis_gen'),
]

