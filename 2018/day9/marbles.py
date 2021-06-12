import sys
import collections

class MarbleGame:
    def __init__(self, players_nb, max_marble):
        self.players_nb = players_nb
        self.max_marble = max_marble
        self._last_consumed_marble = 0
        self._circle = collections.deque([0], max_marble)
        self._current_marble = 0
        self._current_player = 0
        self.players_scores = [0] * players_nb

    def print_round(self):
        """Debug method to see what's going on."""
        round_string = '[{}] '.format(self._current_player)

        for marble in self._circle:
            if marble == self._current_marble:
                round_string += '({})'.format(marble)
            else:
                round_string += ' {} '.format(marble)

        print(round_string)

    def play(self):
        """Plays the game until the last marble"""
        while self._last_consumed_marble < self.max_marble:
            self._last_consumed_marble += 1
            entering_marble = self._last_consumed_marble

            # if (entering_marble % 1000) == 0:
                # print(entering_marble)

            if (entering_marble % 23) != 0:
                self._circle.rotate(-1)
                self._circle.append(entering_marble)
                self._current_marble = entering_marble
            else:
                self._circle.rotate(7)
                spoils = self._circle.pop()
                self.players_scores[self._current_player] += entering_marble
                self.players_scores[self._current_player] += spoils
                self._current_marble = self._circle.popleft()
                self._circle.appendleft(self._current_marble)
                self._circle.rotate(-1)

            # self.print_round()
            self._current_player = (
                (self._current_player + 1) % self.players_nb
            )

if __name__ == '__main__':
    with open(sys.argv[1], mode='r') as f:
        line = f.readline().rstrip('\n').split()
        players_nb = int(line[0])
        max_marble = int(line[6])

    print(players_nb, max_marble)

    game = MarbleGame(players_nb, max_marble)

    game.play()

    print(max(game.players_scores))