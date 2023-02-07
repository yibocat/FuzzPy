import copy

from fuzzynumbers.archimedean cimport ( in_algebraic_tau,
                                        algebraic_tau,
                                        in_algebraic_s,
                                        algebraic_s,
                                        in_einstein_tau,
                                        einstein_tau,
                                        in_einstein_s,
                                        einstein_s)
from ..Fuzzynum cimport Fuzzynum

import numpy as np
cimport numpy as np

cdef class qrungivfn(Fuzzynum):
    cdef readonly:
        int __qrung
        str __parent
        double __score
        double __accuracy
        double __indeterminacy
    cdef:
        np.ndarray __md
        np.ndarray __nmd

    def __init__(self, int qrung, list md, list nmd):
        super().__init__()

        mds = np.asarray(md)
        nmds = np.asarray(nmd)

        assert mds.size == 2 and nmds.size == 2, 'ERROR: The data format contains at least upper and lower bounds.'
        assert mds[0] <= mds[1] and nmds[0] <= nmds[1], \
            'ERROR: The upper limit of membership degree is greater than the lower limit.'
        assert 0 <= mds[0] <= 1 and 0 <= mds[1] <= 1 and 0 <= nmds[0] <= 1 and 0 <= nmds[1] <= 1, \
            'ERROR: The membership degree and non-membership degree must be in the interval 0-1.'
        assert 0 <= mds[0] ** qrung + nmds[0] ** qrung <= 1 and 0 <= mds[1] ** qrung + nmds[1] ** qrung <= 1, \
            'ERROR: The sum of membership degree and non-membership degree must be in the interval 0-1.'

        self.__md = mds
        self.__nmd = nmds
        self.__qrung = qrung

    def __repr__(self):
        return 'QRungIVFN(Q=%d):' % self.__qrung + \
            '(\n MD: [' + str(np.around(self.__md[0], 4)) + ',' + str(np.around(self.__md[1], 4)) + ']\n NMD:[' + str(
                np.around(self.__nmd[0], 4)) + ',' + str(np.around(self.__nmd[1], 4)) + '])'

    property qrung:
        def __get__(self):
            return self.__qrung

    property md:
        def __get__(self):
            return self.__md

        def __set__(self, value):
            m = np.asarray(value)
            om = self.__md
            self.__md = m
            if not self.isLegal():
                self.__md = om
                raise ValueError('ERROR: Invalid data.')

    property nmd:
        def __get__(self):
            return self.__nmd

        def __set__(self, value):
            nm = np.asarray(value)
            onm = self.__nmd
            self.__nmd = nm
            if not self.isLegal():
                self.__nmd = onm
                raise ValueError('ERROR: Invalid data.')

    property parent:
        def __get__(self):
            for base in self.__class__.__bases__:
                self.__parent = base.__name__
                return self.__parent

    property score:
        def __get__(self):
            md = self.__md[0] ** self.__qrung + self.__md[1] ** self.__qrung
            nmd = self.__nmd[0] ** self.__qrung + self.__nmd[1] ** self.__qrung
            self.__score = (md - nmd) / 2
            return self.__score

    property accuracy:
        def __get__(self):
            md = self.__md[0] ** self.__qrung + self.__md[1] ** self.__qrung
            nmd = self.__nmd[0] ** self.__qrung + self.__nmd[1] ** self.__qrung
            self.__accuracy = (md + nmd) / 2
            return self.__accuracy

    property indeterminacy:
        def __get__(self):
            md = self.__md[0] ** self.__qrung + self.__md[1] ** self.__qrung
            nmd = self.__nmd[0] ** self.__qrung + self.__nmd[1] ** self.__qrung
            self.__indeterminacy =  (1 - (md + nmd) / 2) ** (1 / self.__qrung)
            return self.__indeterminacy

    cpdef isEmpty(self):
        if not (self.__md[0] and self.__md[1] and self.__nmd[0] and self.__nmd[1]):
            return True
        else:
            return False

    cpdef isEmpty_half(self):
        if not (self.__md[0] or self.__md[1] or self.__nmd[0] or self.__nmd[1]):
            return True
        else:
            return False

    cpdef isLegal(self):
        if not (self.__md.size == 2 and self.__nmd.size == 2):
            return False
        elif not (self.__md[0] <= self.__md[1] and self.__nmd[0] <= self.__nmd[1]):
            return False
        elif not (0 <= self.__md[0] <= 1 and 0 <= self.__md[1] <= 1 and
                  0 <= self.__nmd[0] <= 1 and 0 <= self.__nmd[1] <= 1):
            return False
        elif not (0 <= self.__md[0] ** self.__qrung + self.__nmd[0] ** self.__qrung <= 1 and
                  0 <= self.__md[1] ** self.__qrung + self.__nmd[1] ** self.__qrung <= 1):
            return False
        else:
            return True

    cpdef comp(self):
        newIVFN = copy.deepcopy(self)
        newIVFN.md = self.__nmd
        newIVFN.nmd = self.__md
        return newIVFN

    cpdef algeb_power(self, double l):
        newIVFN = copy.deepcopy(self)
        newIVFN.md[0] = in_algebraic_tau(l * algebraic_tau(self.__md[0] ** self.__qrung)) ** (1 / self.__qrung)
        newIVFN.md[1] = in_algebraic_tau(l * algebraic_tau(self.__md[1] ** self.__qrung)) ** (1 / self.__qrung)
        newIVFN.nmd[0] = in_algebraic_s(l * algebraic_s(self.__nmd[0] ** self.__qrung)) ** (1 / self.__qrung)
        newIVFN.nmd[1] = in_algebraic_s(l * algebraic_s(self.__nmd[1] ** self.__qrung)) ** (1 / self.__qrung)
        return newIVFN

    cpdef algeb_times(self, double l):
        newIVFN = copy.deepcopy(self)
        newIVFN.md[0] = in_algebraic_s(l * algebraic_s(self.__md[0] ** self.__qrung)) ** (1 / self.__qrung)
        newIVFN.md[1] = in_algebraic_s(l * algebraic_s(self.__md[1] ** self.__qrung)) ** (1 / self.__qrung)
        newIVFN.nmd[0] = in_algebraic_tau(l * algebraic_tau(self.__nmd[0] ** self.__qrung)) ** (1 / self.__qrung)
        newIVFN.nmd[1] = in_algebraic_tau(l * algebraic_tau(self.__nmd[1] ** self.__qrung)) ** (1 / self.__qrung)
        return newIVFN

    cpdef eins_power(self, double l):
        newIVFN = copy.deepcopy(self)
        newIVFN.md[0] = in_einstein_tau(l * einstein_tau(self.__md[0] ** self.__qrung)) ** (1 / self.__qrung)
        newIVFN.md[1] = in_einstein_tau(l * einstein_tau(self.__md[1] ** self.__qrung)) ** (1 / self.__qrung)
        newIVFN.nmd[0] = in_einstein_s(l * einstein_s(self.__nmd[0] ** self.__qrung)) ** (1 / self.__qrung)
        newIVFN.nmd[1] = in_einstein_s(l * einstein_s(self.__nmd[1] ** self.__qrung)) ** (1 / self.__qrung)
        return newIVFN

    cpdef eins_times(self, double l):
        newIVFN = copy.deepcopy(self)
        newIVFN.md[0] = in_einstein_s(l * einstein_s(self.__md[0] ** self.__qrung)) ** (1 / self.__qrung)
        newIVFN.md[1] = in_einstein_s(l * einstein_s(self.__md[1] ** self.__qrung)) ** (1 / self.__qrung)
        newIVFN.nmd[0] = in_einstein_tau(l * einstein_tau(self.__nmd[0] ** self.__qrung)) ** (1/self.__qrung)
        newIVFN.nmd[1] = in_einstein_tau(l * einstein_tau(self.__nmd[1] ** self.__qrung)) ** (1/self.__qrung)
        return newIVFN
