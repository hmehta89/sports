from rest_framework import serializers
from .models import Match


class MatchSerializer(serializers.ModelSerializer):
    home_team_name = serializers.CharField(source='home_team.name', read_only=True)
    away_team_name = serializers.CharField(source='away_team.name', read_only=True)

    class Meta:
        model = Match
        fields = [
            'id', 'home_team', 'home_team_name', 'away_team', 'away_team_name',
            'date', 'home_score', 'away_score', 'status',
        ]

    def validate(self, data):
        home = data.get('home_team')
        away = data.get('away_team')
        if home and away and home == away:
            raise serializers.ValidationError("home_team and away_team must be different.")
        return data


class UpdateScoreSerializer(serializers.Serializer):
    home_score = serializers.IntegerField(min_value=0)
    away_score = serializers.IntegerField(min_value=0)
    status = serializers.ChoiceField(
        choices=Match.STATUS_CHOICES, default=Match.STATUS_LIVE
    )
