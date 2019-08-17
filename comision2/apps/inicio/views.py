
from django.shortcuts import render, redirect, HttpResponse
from django.contrib.auth.models import User
from apps.presidente.forms import RegistroForm


from django.views.generic import CreateView, View
from django.urls import reverse_lazy

from django.contrib.auth import authenticate, login

from django.contrib import messages
from apps.inicio.models import AuthUser

import time








#datos del USER
class RegistrarUsuario(CreateView):
	model = User 
	template_name="crear_user.html"
	form_class = RegistroForm
	success_url=reverse_lazy('p_auth_lis')

  
def index(request):
	return render(request,'index.html')


def mylogin(request):

    if request.method == 'POST':
        
        username = request.POST['username']
        password = request.POST['password']
        user = authenticate(request, username=username, password=password)
        if user is not None:
            login(request, user)
            #aqui va la lógica de usuario
            if user.has_perm('inicio.es_canalero'):
                return redirect('canalero')
            elif user.has_perm('inicio.es_presidente'):
                return redirect('presidente')
            elif user.has_perm('inicio.es_vocal'):
                return redirect('vocal')
            elif user.has_perm('inicio.es_tesorero'):
                return redirect('tesorero')       
            else:
                return redirect('usuario')
        else:
            messages.info(request, 'Corrija los datos')
            return render(request, 'login.html')
    else:
        return render(request, 'login.html')


"""
            messages.debug(request, 'SQL statements were executed.')
            messages.info(request, 'Three credits remain in your account.')
            messages.success(request, 'Profile details updated.')
            messages.warning(request, 'Your account expires in three days.')
            messages.error(request, 'Document deleted.')

"""
