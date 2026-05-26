from django.db import models
from teams.models import Team


class Player(models.Model):
    name = models.CharField(max_length=100)
    team = models.ForeignKey(Team, on_delete=models.CASCADE, related_name='players')
    position = models.CharField(max_length=50)
    jersey_number = models.PositiveIntegerField()
    age = models.PositiveIntegerField()

    class Meta:
        ordering = ['team', 'jersey_number']
        unique_together = [('team', 'jersey_number')]

    def __str__(self):
        return f"#{self.jersey_number} {self.name} ({self.team})"
