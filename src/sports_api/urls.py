from django.urls import path, include

urlpatterns = [
    path('api/', include('teams.urls')),
    path('api/', include('players.urls')),
    path('api/', include('matches.urls')),
]
