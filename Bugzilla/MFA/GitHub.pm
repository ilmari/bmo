# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This Source Code Form is "Incompatible With Secondary Licenses", as
# defined by the Mozilla Public License, v. 2.0.

package Bugzilla::MFA::GitHub;

use 5.10.1;
use strict;
use warnings;
use base 'Bugzilla::MFA';

sub prompt {
    my ($self, $vars) = @_;
    my $template = Bugzilla->template;

    print Bugzilla->cgi->header();
    $template->process('mfa/github/verify.html.tmpl', $vars)
        || ThrowTemplateError($template->error());
}

1;
