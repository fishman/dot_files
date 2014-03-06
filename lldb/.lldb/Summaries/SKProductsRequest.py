#! /usr/bin/env python
# -*- coding: utf-8 -*-

# The MIT License (MIT)
#
# Copyright (c) 2013 Bartosz Janda
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import lldb
import NSSet
import SKRequest
import objc_runtime
import summary_helpers

statistics = lldb.formatters.metrics.Metrics()
statistics.add_metric('invalid_isa')
statistics.add_metric('invalid_pointer')
statistics.add_metric('unknown_class')
statistics.add_metric('code_notrun')


class SKProductsRequest_SynthProvider(SKRequest.SKRequest_SynthProvider):
    # SKProductsRequest:
    # Offset / size                                         32bit:              64bit:
    #
    # Class isa                                              0 = 0x00 / 4        0 = 0x00 / 8
    # SKRequestInternal *_requestInternal                    4 = 0x04 / 4        8 = 0x08 / 8
    # SKProductsRequestInternal *_productsRequestInternal    8 = 0x08 / 4       16 = 0x10 / 8

    # SKProductsRequestInternal:
    # Offset / size                                         32bit:              64bit:
    #
    # Class isa                                              0 = 0x00 / 4        0 = 0x00 / 8
    # NSSet *_productIdentifiers                             4 = 0x04 / 4        8 = 0x08 / 8

    def __init__(self, value_obj, sys_params, internal_dict):
        super(SKProductsRequest_SynthProvider, self).__init__(value_obj, sys_params, internal_dict)
        self.value_obj = value_obj
        self.sys_params = sys_params
        self.internal_dict = internal_dict
        self.products_request_internal = None
        self.product_identifiers = None
        self.product_identifiers_provider = None
        self.update()

    def update(self):
        super(SKProductsRequest_SynthProvider, self).update()
        # _productsRequestInternal (self->_productsRequestInternal)
        self.products_request_internal = self.value_obj.GetChildMemberWithName("_productsRequestInternal")
        #self.products_request_internal = self.value_obj.CreateChildAtOffset("_productsRequestInternal",
        #                                                                    2 * self.sys_params.pointer_size,
        #                                                                    self.sys_params.types_cache.id)
        self.product_identifiers = None
        self.product_identifiers_provider = None

    def adjust_for_architecture(self):
        super(SKProductsRequest_SynthProvider, self).adjust_for_architecture()

    # _productIdentifiers (self->_internal->_productIdentifiers)
    def get_product_identifiers(self):
        if self.product_identifiers:
            return self.product_identifiers

        if self.products_request_internal:
            self.product_identifiers = self.products_request_internal.CreateChildAtOffset("productIdentifiers",
                                                                                          1 * self.sys_params.pointer_size,
                                                                                          self.sys_params.types_cache.NSSet)
        return self.product_identifiers

    # NSSet provider
    def get_product_identifiers_provider(self):
        if self.product_identifiers_provider:
            return self.product_identifiers_provider

        if self.get_product_identifiers():
            self.product_identifiers_provider = NSSet.GetSummary_Impl(self.get_product_identifiers())
        return self.product_identifiers_provider

    def summary(self):
        count = 0
        if self.get_product_identifiers_provider():
            count = self.get_product_identifiers_provider().count
        if count == 1:
            summary = "@\"{} product\"".format(count)
        else:
            summary = "@\"{} products\"".format(count)
        return summary


def SKProductsRequest_SummaryProvider(value_obj, internal_dict):
    # Class data
    global statistics
    class_data, wrapper = objc_runtime.Utilities.prepare_class_detection(value_obj, statistics)
    summary_helpers.update_sys_params(value_obj, class_data.sys_params)
    if wrapper is not None:
        return wrapper.message()

    wrapper = SKProductsRequest_SynthProvider(value_obj, class_data.sys_params, internal_dict)
    if wrapper is not None:
        return wrapper.summary()
    return "Summary Unavailable"


def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand("type summary add -F SKProductsRequest.SKProductsRequest_SummaryProvider \
                            --category StoreKit \
                            SKProductsRequest")
    debugger.HandleCommand("type category enable StoreKit")
