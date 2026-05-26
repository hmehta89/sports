from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Match
from .serializers import MatchSerializer, UpdateScoreSerializer


class MatchViewSet(viewsets.ModelViewSet):
    queryset = Match.objects.select_related('home_team', 'away_team').all()
    serializer_class = MatchSerializer

    @action(detail=True, methods=['post'], url_path='update_score')
    def update_score(self, request, pk=None):
        match = self.get_object()
        serializer = UpdateScoreSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        match.home_score = serializer.validated_data['home_score']
        match.away_score = serializer.validated_data['away_score']
        match.status = serializer.validated_data['status']
        match.save(update_fields=['home_score', 'away_score', 'status'])

        return Response(MatchSerializer(match).data, status=status.HTTP_200_OK)
