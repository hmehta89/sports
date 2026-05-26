from rest_framework import serializers
from .models import Player


class PlayerSerializer(serializers.ModelSerializer):
    team_name = serializers.CharField(source='team.name', read_only=True)

    class Meta:
        model = Player
        fields = ['id', 'name', 'team', 'team_name', 'position', 'jersey_number', 'age']
