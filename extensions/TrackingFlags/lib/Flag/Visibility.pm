# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This Source Code Form is "Incompatible With Secondary Licenses", as
# defined by the Mozilla Public License, v. 2.0.

package Bugzilla::Extension::TrackingFlags::Flag::Visibility;

use base qw(Bugzilla::Object);

use 5.10.1;
use strict;
use warnings;

use Bugzilla::Error;
use Bugzilla::Product;
use Bugzilla::Component;
use Scalar::Util qw(blessed);

###############################
####    Initialization     ####
###############################

use constant DB_TABLE => 'tracking_flags_visibility';

use constant DB_COLUMNS => qw(
    id
    tracking_flag_id
    product_id
    component_id
);

use constant LIST_ORDER => 'id';

use constant UPDATE_COLUMNS => (); # imutable

use constant VALIDATORS => {
    tracking_flag_id => \&_check_tracking_flag,
    product_id       => \&_check_product,
    component_id     => \&_check_component,
};

###############################
####      Methods          ####
###############################

sub match {
    my $class= shift;
    my ($params) = @_;
    my $dbh = Bugzilla->dbh;

    # Allow matching component and product by name
    # (in addition to matching by ID).

    if (!$params->{product_id} && $params->{product}) {
        my $product;
        if (blessed $params->{product}) {
            $product = delete $params->{product};
        }
        else {
            ThrowCodeError("tracking_flags_invalid_param", { name => "product", value => delete $params->{product} });
        }
        $params->{product_id} = $product->id;
    }

    if (!$params->{component_id} && $params->{component}) {
        my $component;
        if (blessed $params->{component}) {
            $component = delete $params->{component};
        }
        else {
            ThrowCodeError("tracking_flags_invalid_param", { name => "component", value => delete $params->{component} });
        }
        $params->{component_id} = $component->id;
    }

    delete $params->{$_} for qw( is_active component product );

    return $class->SUPER::match($params);
}

###############################
####      Validators       ####
###############################

sub _check_tracking_flag {
    my ($invocant, $flag) = @_;
    if (blessed $flag) {
        return $flag->flag_id;
    }
    $flag = Bugzilla::Extension::TrackingFlags::Flag->new($flag)
        || ThrowCodeError('tracking_flags_invalid_param', { name => 'flag_id', value => $flag });
    return $flag->flag_id;
}

sub _check_product {
    my ($invocant, $product) = @_;
    if (blessed $product) {
        return $product->id;
    }
    $product = Bugzilla::Product->new($product)
        || ThrowCodeError('tracking_flags_invalid_param', { name => 'product_id', value => $product });
    return $product->id;
}

sub _check_component {
    my ($invocant, $component) = @_;
    return undef unless defined $component;
    if (blessed $component) {
        return $component->id;
    }
    $component = Bugzilla::Component->new($component)
        || ThrowCodeError('tracking_flags_invalid_param', { name => 'component_id', value => $component });
    return $component->id;
}

###############################
####      Accessors        ####
###############################

sub tracking_flag_id { return $_[0]->{'tracking_flag_id'}; }
sub product_id       { return $_[0]->{'product_id'};       }
sub component_id     { return $_[0]->{'component_id'};     }

sub tracking_flag {
    my ($self) = @_;
    $self->{'tracking_flag'} ||= Bugzilla::Extension::TrackingFlags::Flag->new($self->tracking_flag_id);
    return $self->{'tracking_flag'};
}

sub product {
    my ($self) = @_;
    $self->{'product'} ||= Bugzilla::Product->new($self->product_id);
    return $self->{'product'};
}

sub component {
    my ($self) = @_;
    return undef unless $self->component_id;
    $self->{'component'} ||= Bugzilla::Component->new($self->component_id);
    return $self->{'component'};
}

1;
