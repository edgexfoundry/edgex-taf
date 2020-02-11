import logging
import subprocess


class Cli:
    def __init__(self):
        self.log = logging.getLogger(__name__)
        pass

    def get_profiles(self):
        self.log.debug('Get Profiles called')
        output = self.send_command('edgex-cli profile list')
        lines = output.splitlines()
        headers = lines.pop(0).split('\t')
        keys = []
        profiles = []
        for header in headers:
            if header != "":
                keys.append(header)
        for line in lines:
            field_count = 0
            profile = {}
            for field in line.split('\t'):
                if field != "":
                    profile[keys[field_count]] = field
                    field_count += 1
            profiles.append(profile)
            self.log.debug('Profile:{}'.format(profile))
        return profiles

    def send_command(self, command=""):
        if command == "":
            return []
        else:
            self.log.debug('Sending command {}'.format(command))
            test = subprocess.Popen(command.split(), stdout=subprocess.PIPE)
            output = test.communicate()[0].decode('utf-8')
            self.log.debug('Output of command: {}'.format(output))
            return output
