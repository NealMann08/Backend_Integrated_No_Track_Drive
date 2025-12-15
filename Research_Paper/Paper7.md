Permission to make digital or hard copies of all or part of this work for personal or
classroom use is granted without fee provided that copies are not made or distributed
for profit or commercial advantage and that copies bear this notice and the full citation
on the first page. Copyrights for components of this work owned by others than ACM
must be honored. Abstracting with credit is permitted. To copy otherwise, or republish,
to post on servers or to redistribute to lists, requires prior specific permission and/or a
fee. Request permissions from permissions@acm.org.
LocalRec’18, November 6, 2018, Seattle, WA, USA
© 2018 Association for Computing Machinery.
ACM ISBN 978-1-4503-6040-1/18/11.
https://doi.org/10.1145/3282825.3282832
Secure Computing of GPS Trajectory Similarity: A Review
Akshay Chandra Pesara
Albany Lab for Privacy and Security
College of Engineering and Applied
Sciences
University at Albany, SUNY
Albany, NY, USA
apesara@albany.edu
Vikram Patil
Albany Lab for Privacy and Security
College of Engineering and Applied
Sciences
University at Albany, SUNY
Albany, NY, USA
vpatil@albany.edu
ABSTRACT
Location Based Services (LBS) powered apps generate a massive
amount of GPS trajectory data everyday. Because many of these
trajectories are similar, if not exactly the same, (e.g., people travel-
ing together or taking the same route everyday), there is a signifi-
cant amount of redundancy in the data generated. This redundant
data increases storage cost and network bandwidth cost. In order
to counteract this and efficiently provide the LBS, LBS providers
are considering trajectory similarity computation. There are several
methods reported in the literature regarding similarity in GPS trajec-
tories, which directly work on data in the plaintext format. However,
computing trajectory similarity traditionally introduces privacy and
security concerns among users since the number of incidents of the
privacy breaches is on the rise. Hence, researchers have recently
come up with innovative ways to perform trajectory similarity op-
erations in the encrypted domain, without revealing the actual data.
These approaches increase privacy and boost user confidence, which
results in more customers for LBS providers. In this paper, we re-
view various methods proposed in the plaintext domain and in the
encrypted domain for secured trajectory comparison. We also dis-
cuss potential methods for encrypted domain computing that can be
used in the domain of trajectory similarity and list the open research
challenges.
CCS CONCEPTS
• Security and Privacy; • Security Services; • Privacy-preserving
protocols;
KEYWORDS
GPS, Trajectory similarity, LBS, Privacy
1 INTRODUCTION
Smartphone users all over the world are generating a massive amount
of GPS data every day which is stored by the LBS providers. The
number of smartphone users are growing every year. The storage
cost for managing such quantities of data is very high. According to
Pradeep K. Atrey
Albany Lab for Privacy and Security
College of Engineering and Applied
Sciences
University at Albany, SUNY
Albany, NY, USA
patrey@albany.edu
the Markets and Markets report [21], the Location-Based Services
(LBS) and Real-Time Location Systems (RTLS) market is expected
to rise to USD 68.85 billion by 2023.
In many cases, people travel in groups, for example in a bus, train
or a cab. In all these scenarios, the GPS trajectory of most of the
users is similar, but it is not exactly the same since their relative GPS
coordinates differ slightly. This results in high redundancy of the data
and increases the storage cost, network bandwidth to transfer data,
etc. If LBS providers could come up with a way to find the similarity
in the trajectories, then they can reduce this redundancy. Furthermore,
trajectory similarity computation has several applications such as
prediction of a user’s location, driverless cars, anomaly detection
in the trajectory, etc. One of the most interesting applications of
the trajectory similarity is ride-sharing or carpooling, in which the
app-based cab services like Uber, Lyft, etc. determine if multiple
users can share a ride cab by comparing their trajectories. Consider
for example a business model where the LBS provider offers food
delivery and cab services such as Uber. If a situation arises where
a customer is to be picked up, and food has to be delivered to a
different customer, the service cost would include the cost of two
different trips. Computing trajectory similarity will let the LBS
provider know if the routes of the two users are similar.
LBS providers suggest that users turn on the location tracking
in their smartphones to utilize additional services. When the user
gives permission to access location data, the LBS providers gain
access to collect the user’s GPS trajectory data. According to the Q2
2018 Mobile Threat Report referenced in a news article by Stephen
Silver from AppleInsider [2], 2200 unsecured Firebase databases
have caused more than 3000 iOS and Android related applications to
leak over 100 million records of users’ GPS location data and other
personal information. GPS data is very sensitive, and it can expose
the personal information of users. The recent spike in the data breach
related incidents is making users anxious to share their data with
the LBS providers. Safeguarding the privacy of the users’ data has
become the top priority for LBS providers. An LBS provider can be
semi-malicious/curious and can potentially misuse the users’ GPS
trajectory data. If an adversary accesses this data, then this can lead
to disastrous circumstances. Hence we need to come up with ways
to provide LBS while protecting the GPS data from the adversaries
and curious LBS providers.
If the users’ GPS trajectory data is processed in a secure way by
the LBS providers, it cannot be accessed by external adversaries or
the curious LBS providers. This increases the credibility of the LBS
provider and in turn, builds the trust of the users’. Hence researchers
have recently discovered methods to perform trajectory similarity
computation in the encrypted domain.
Previously researchers had published survey papers for trajectory
similarity methods in the plaintext domain [18, 19, 31, 37]. To the
best of our knowledge, this is the first survey paper to provide
an overview of trajectory similarity computation methods in the
encrypted domain.
The rest of the paper is organized as follows, the research work on
trajectory similarity computation in plaintext domain is summarized
in Section 2. In Section 3, we first describe the existing research
work on encrypted domain trajectory similarity computation and
then discuss the potential methods that can be explored in the future
for trajectory similarity computation in encrypted domain. Section 4
lists open research challenges and potential improvements to existing
methods and Section 5 concludes the paper.
2 TRAJECTORY SIMILARITY
COMPUTATION IN PLAINTEXT DOMAIN
Since the amount of GPS trajectory data being generated everyday
is increasing, analyzing trajectory data and finding patterns and sim-
ilarity between them has become a critical problem. To determine
if given trajectories are similar, researchers have coined the term
‘trajectory similarity function’, which uses one of the popular trajec-
tory similarity measures. Table 1 provides an overview of plaintext
domain methods for trajectory similarity computation.
We provide background regarding similarity functions in Section
2.1. We discuss existing research work from literature Section 2.2,
and we list the surveys previously published related to trajectory
similarity computation in plaintext domain in Section 2.3.
2.1 Background
The trajectory similarity function takes two trajectories as input and
evaluates if the given two trajectories are similar. The most common
similarity functions used for computing trajectory similarity in the
literature are based on Euclidean Distance (ED), Dynamic Time
Warping (DTW), Edit Distance with Real Penalty (ERP), Edit Dis-
tance on Real Sequence (EDR) and Longest Common Sub Sequence
(LCSS) which are explained as follows.
(1) ED is the measure of the straight line distance between two
points in Euclidean space. It is a distance function used to
measure the similarity between time series data [1]. It is an
effective and faster method but requires two trajectories of
the same length to calculate similarity. Furthermore, it does
not support local time shifting.
(2) DTW is a distance function introduced to handle local time
shifting and time sequences with different lengths [12, 13, 40].
However, this function is slower than ED and cannot handle
noise.
(3) LCSS is a popular method in various domains such as string
manipulations, etc. and has been used to detect trajectory
similarity. LCSS is based on ED, and is better than ED in
terms of handling noise and local time shifting. However, the
drawback is that it sacrifices accuracy when there is higher
noise [4].
(4) Chen in [4], described ERP as a distance metric function
based on edit distance that supports local time shifting and
triangle inequality but cannot handle noise.
Table 1: Trajectory Similarity Computation Methods in Plain-
text Domain
Approach Author Superior To
In con-
text
of
Datasets
used
LCSS Vlachos
et al. [35]
DTW and
ED
Handling
noise
Marine
mammals
[34], ASL
[11]
EDR Chen et
al. [5]
ED, DTW,
ERP and
LCSS
Handling
noise and
Local
time shift
ASL[11],
Camera
Mouse [34]
MD
Ismail
and Vi-
gneron
[10]
ED
Sub-
sampling,
Super-
sampling
T Drive [41,
42]
SDTW Mao et al.
[20]
LCSS, EDR
and DTW Sampling
Geolife
[43],
CVRR [22]
OCJ Guo et al.
[7] FD
Efficiency,
Scalabil-
ity
T Drive [41,
42]
∗ED- Euclidean Distance,DTW - Dynamic Time
Warping,LCSS-Longest Common Sub Sequence, ERP - Edit
Distance with Real Penalty, EDR - Edit Distance on Real Sequence,
SDTW - Segment based Dynamic Time Warping, FD - Frechet
Distance, OCJ - Ordered Coverage Judge
(5) EDR is defined by Chen in [4] as a distance function which
is introduced to handle noise and which supports local time
shifting as well as near triangle inequality.
In addition to the measures mentioned above, there are several
other methods proposed by researchers such as Frechet Distance etc.
which are discussed later in the paper.
In [35], Vlachos et al. proposed a trajectory similarity measure
function based on LCSS. Their method was compared to traditional
DTW and ED measures and proved to be far superior in terms
of clustering performance when noise is present in the trajectory
data. This method does not require normalized data and offers a
comparison between all the sequence pairs in the trajectory by sliding
the smaller of two trajectories and recording the minimum distance
between them [35].
Trajectory similarity has been a well-studied problem for a long
time. Although GPS data is the main focus today, but other areas
such as time series data, movement of marine animals, patterns in
shapes etc. have also been explored with similar techniques.
2.2 Existing Research Work on GPS Trajectory
Similarity Computation
Researchers have proposed enhanced algorithms based on the simi-
larity functions discussed earlier. These new algorithms are effective
in terms of handling noise, local time shifting and sampling, and are
scalable to large datasets.
In [10], Ismail and Vigneron presented a new algorithm called
Merge Distance (MD) to measure the similarity between GPS tra-
jectories which is robust against sub-sampling and super-sampling.
They compared their new measure function with DTW and ED by us-
ing the truck dataset and the T Drive dataset [41, 42]. In [20], Mao et
al. proposed a new technique based on DTW called Segment based
Dynamic Time Warping (SDTW) algorithm. Their method com-
bines three distances: point-segment distance, prediction distance
and segment-segment distance. They claim that SDTW is accurate
and less sensitive to noise than LCSS, EDR, and DTW. In [7], Guo
et al. proposed an algorithm based on Frechet Distance called Or-
dered Coverage Judge (OCJ) which is able to realize a filtered query
with a given Frechet Distance on a large-scale trajectory dataset.
They claim that OCJ is efficient and faster in certain cases and that
parallel implementation of OCJ can achieve maximum advantages
for stability, parallel efficiency and time cost of the algorithm. The
computational complexity of OCJ is O(pq)where p is the length of
the first trajectory, and q is the length of the second trajectory. Table
1 describes various methods for trajectory similarity computation in
the plaintext domain.
2.3 Survey Papers on Trajectory Similarity
Computation in Plaintext Domain
There are a few survey papers on trajectory similarity computation
available in the literature. Most of these survey papers focus on the
comparison of various similarity measures. In this section, we give
an overview of these survey papers.
In [37], Wang et al. define trajectory transformations such as
adding noise, increasing/ decreasing sampling rate, and random and
synchronized shifts in the trajectory for the comparison of various
similarity measures. They use these trajectory transformations to
compare the effectiveness of various similarity measures (ED, DTW,
Piecewise DTW (PDTW), EDR, ERP, and LCSS). They have per-
formed extensive experiments using the Beijing taxi trajectories
dataset to report their observations. In [31], Toohey and Duckham
implemented the four similarity measures (LCSS, Frechet Distance,
DTW, and Edit distance) in R language package and published it on
CRAN. They also perform an empirical evaluation of those similarity
measures.
In [19], Magdy et al. provide the classification of various similar-
ity measures based on spatiotemporal similarity and spatial similarity
which are further divided into sub-classifications based on similari-
ties of Movement speed, Time series, Spatial Data, Geometric Shape
and Movement. They also provide an excellent comparison of the
similarity measures based on time complexity, robustness etc.
The existing survey papers only cover methods in plaintext do-
main whereas in this paper our focus is to review the applicability
of these methods in the encrypted domain. Furthermore, we cover
the proximity testing methods that are closely related to trajectory
similarity methods. Although there has been extensive research con-
ducted in the plaintext domain, the methods suffer from the serious
drawback of lack of privacy and security of users’ data.
3 TRAJECTORY SIMILARITY
COMPUTATION IN ENCRYPTED DOMAIN
In order to secure the GPS data from adversaries, researchers have
proposed computing trajectory similarity in the encrypted domain.
Secure Trajectory Similarity Measure is a function between two
encrypted trajectories, which computes if the two trajectories are
similar. These techniques are developed to ensure that the owner of a
trajectory should not learn anything about the other trajectory or the
other party except the result of similarity computation. To achieve
this, researchers have proposed various techniques.
In the following subsections, first we provide the background
information on the various cryptographic techniques (in Section 3.1).
Then, we discuss the existing methods for computing the trajectory
similarity in encrypted domain (in Section 3.2). Finally, we discuss
the potential methods which could be used for this purpose (in
Section 3.3).
3.1 Background
In general, when data is encrypted, it has to be decrypted before
operations can be performed on it. However, there are a few meth-
ods which allow operations directly on the encrypted data. These
methods fall under the category of secured multi-party computa-
tion (SMC). These methods provide robust security against semi-
malicious/curious service provider who wants to know users’ data
as well as against an external adversary. The popular methods for
encryption and secured computation used in secured trajectory sim-
ilarity computation are garbled circuits, secret sharing based ap-
proaches and well known homomorphic encryption schemes like
Paillier and ElGamal cryptosystems. Table 2 provides an overview
of these methods.
Homomorphic encryption allows computations on ciphertext, the
result of which matches the result of the same computation on the
plaintext data when decrypted. The popular homomorphic schemes
are the Paillier and ElGamal cryptosystems which support certain
operations. Homomorphic encryption allows simple arithmetic oper-
ations such as addition and multiplication, but computing trajectory
similarity securely is challenging. Hence, researchers have used a
combination of different cryptographic concepts to achieve secure
trajectory similarity computation.
In Shamir’s Secret Sharing algorithm, the message is divided into
multiple shares and in order to retrieve the original message, the
user needs a certain minimum number of those shares. This method
was introduced by Adi Shamir in [29]. This algorithm has been used
extensively in multiple domains and is also used by researchers to
compute trajectory similarity.
Yao’s garbled circuits method [16, 39] allows two semi-honest
users to come up with an arbitrary function without leaking any
information about the user’s inputs. The protocol consists of two
parties in which one party generates a garbled circuit to compute the
function known as a constructor, and the other party computes the
output of the circuit known as the evaluator without learning any in-
termediate values. This protocol helps to solve the famous “socialist
millionaire’s problem”. In the socialist millionaire’s problem, two
millionaires want to know if their wealth is equal without disclosing
any information about their wealth to each other. By combining
homomorphic encryption based cryptosystems and garbled circuits,
Table 2: Research on Secure Trajectory Similarity Computa-
tion
Goal Author Approach
Proximity preserving ride
sharing using trajectory
similarity computation
Hallgren et
al. [8]
Paillier cryptosys-
tem and Shamir’s
secret sharing
Secure trajectory similar-
ity computation
Liu et al.
[17]
Paillier cryptosys-
tem and garbled cir-
cuits
Secure private equality
testing
Narayanan
et al. [23]
ElGamal encryption
for synchronous
PET, location tags
for asynchronous
PET
Efficient private equiva-
lence testing using VPET
Saldamli et
al. [26]
Proximity testing by
symmetric key en-
cryption using AES
Privacy preserving prox-
imity system based on
GSM cellular location
tags
Lin et al.
[15]
De-duplication shin-
gling to test loca-
tion tag similarity
by equality testing
user-controlled privacy Geosocial query with
Hu et al. [9] Proximity testing
based on SWHE
∗VPET - Vectorial Private Equivalence Testing,∗SWHE - Some
What Homomorphic Encryption
researchers have proposed various methods for trajectory similarity
computation in the encrypted domain.
Private proximity testing methods can also be considered for
trajectory similarity computation as this concept allows two users to
know if they are nearer to each other at different levels of granularity.
These techniques compare the geographic location of the users and
find the relative distance between them. Instead of two points, if we
apply these methods to multiple points of trajectories, then these
methods can help us in determining if the corresponding points of the
trajectory are close to one another and ultimately if the trajectories
are similar. In the literature, several secure protocols have been
proposed for proximity testing which will be discussed later in this
paper.
3.2 Existing Methods for Secure GPS Trajectory
Similarity Computation
In this section, we discuss the research based on garbled circuits,
homomorphic encryption and garbled circuits, and proximity testing.
3.2.1 Homomorphic encryption and Shamir’s secret sharing.
In [8], Hallgren et al. proposed a method for privacy preserving ride-
sharing which is an application of trajectory similarity computation.
Their model enables users to perform ride matching by determining
both proximity of end points and by trajectory matching. They have
used homomorphic encryption for end point matching and developed
a protocol for threshold private set intersection (T-PSI) based on
Shamir’s Secret Sharing for trajectory matching.
3.2.2 Homomorphic encryption and garbled circuit. Researchers
have combined Homomorphic Encryption and Garbled circuits to
propose methods for trajectory similarity detection. In [27], Saman-
thula et al. proposed a hybrid protocol that uses homomorphic en-
cryption and garbled circuit techniques to evaluate complex queries
over encrypted data, which is efficient enough to combine predicate
results securely. In [17], Liu et al. proposed a method to study secure
similarity computation of trajectories in the encrypted domain which
supports most of the primary trajectory distance measure functions
like DTW, LCSS, and EDR. The authors proposed an efficient proto-
col to calculate the squared ED between encrypted trajectories called
Data Packing based Secure Squared Euclidean Distance (DPSSED)
using secure multiplication protocol related to homomorphic addi-
tion and additive secret sharing. It then uses Yao’s garbled circuits
to securely compare the encrypted trajectories [17]. In [14], Li et
al. proposed a hybrid protocol called Secure Comparison over En-
crypted Data (SCED) using homomorphic encryption and garbled
circuits which is efficient and reduces the number of encryptions
and decryptions involved in the implementation.
In [33], Veugen presented a new comparison protocol for the mil-
lionaire’s problem that requires less memory and low computational
cost. The proposed protocol is called LSIC (Lightweight Secure
Integer Comparison) and involves fewer encryptions and decryp-
tions to achieve the results and the performance. In [36], Wang et al.
proposed two schemes for efficient and privacy-preserving computa-
tion on outsourced data on the cloud in which the data is encrypted
under multiple keys with the help of two non-colluding servers. The
schemes are based on ElGamal based proxy re-encryption and by
using their schemes, one user can encrypt data using one’s own
public key and store encrypted data in the cloud. The outsourced
data can later be decrypted by using the private key. These schemes
were proposed to handle the scenario of multiple key setting as fully
homomorphic encryption (FHE), and garbled circuits only focus on
encrypted data computation under a single key setting. In [36], Wang
et al. also mention that other approaches available in the literature
that are based on homomorphic encryption schemes in multiple key
settings are not efficient.
3.2.3 Proximity testing. Proximity testing and trajectory simi-
larity are very closely related problems. In [23], Narayanan et al.
described secure private proximity testing protocols. This further
narrows proximity testing to Private Equality Testing (PET). They
provide protocols for both synchronous and asynchronous private
equality testing. The authors also described the use of location tags
to improve the security of proximity testing. Subsequently, Lin et al.
[15] built on the work of Narayanan et al. by successfully capturing
location tags based on the GSM cellular network. They also used a
de-duplication technique known as shingling to test location tag sim-
ilarity by private equality testing. They also used the GSM cellular
network for the location tags.
In [26], Saldamli et al. proposed a three-party protocol called
Vectorial Private Equivalence Testing (VPET) based on geometry
and linear algebra for PET making it more efficient by reducing
the number of encryptions involved, thus decreasing the server load.
In [9], Hu et al. proposed cryptographic algorithms based on spa-
tial cloaking which can solve user co-location problem. They use
somewhat homomorphic encryption (SHE). Using these protocols,
queries such as ‘Where is the user?’, ‘Who is nearby?’, and ‘How
close is a user to another user?’ can be answered while keeping the
user’s location data and preferences encrypted.
3.2.4 Non-encryption based methods. Tian et al. in [30] pro-
posed a semantic tree based trajectory similarity measuring algo-
rithm to discover social ties between users with the help of cloaked
trajectories. By using cloaked trajectories, they were able to preserve
the privacy of users and they report that their method can achieve
better performance in social tie detection as compared to existing
methods.
3.3 Potential Methods for Trajectory Similarity
Computation in Encrypted Domain
Although there have been several methods in the literature for se-
cured trajectory similarity computation, there are many techniques
which offer alternatives for secure integer comparison and other se-
cured domain operations. Even though these methods are proposed
for other domains, they can potentially be modified and applied
towards securely comparing GPS trajectory data. The following
approaches provide different methods for comparing encrypted data.
In database domain, Popa et al. [25] published a system “CryptDB”
in which the authors developed a system to execute SQL queries
over encrypted data. This system allows encrypted queries, hence
semi-malacious/curious DBAs and adversaries cannot gain access
to the database. In CryptDB, the authors used an SQL aware en-
cryption strategy which executes SQL queries over encrypted data
to obtain results like standard SQL queries on databases. The data
related to trajectories can be encrypted using a common public key
cryptosystem before uploading to the database. Also, Boneh and
Waters [3] presented a general framework for constructing public
key systems that support comparison, conjunctive and range queries
on encrypted data. In this work, the authors proposed a Hidden Vec-
tor Encryption (HVE) scheme to construct a searchable encryption
system that performs comparison and subset queries over encrypted
data efficiently. By using HVE, a public key searchable encryption
system can be built to run subset and range queries on encrypted data.
This approach can potentially be used to encrypt, a set of trajectories
and stored in a database. Using subset operation, it is possible to
determine if a user’s encrypted trajectory exists in a chunk of other
encrypted trajectories. Also, it is possible to determine if the user’s
trajectory belongs in a range of other trajectories in the encrypted
domain.
From the perspective of homomorphic encryption methods, Xu
et al. [38] have presented an implementation of FHE system which
can perform addition, subtraction, multiplication, and division of
integers in encrypted domain. This method can be used to compute
whether two encrypted trajectories are equal, however its compu-
tational complexity could a concern. Previously, Damgard et al.
[6] proposed a homomorphic cryptosystem, which is efficient than
Paillier cryptosystem. They also introduce a comparison protocol
based on additive secret sharing homomorphic evaluation which has
applications for a secure online auction system. This method can
be extended to compare trajectories. Also, Samanthula et al. [28]
proposed a secure bitwise comparison protocol to securely compare
encrypted data by using the additive homomorphic encryption based
Paillier cryptosystem. The concept is implemented on integers en-
crypted using the Paillier cryptosystem. The same approach can be
used for comparing trajectory data.
4 OPEN RESEARCH CHALLENGES
Although there have been a number of works related to secured
trajectory computation with some success, there are several open
research challenges in this area. We discuss them as follows :
(1) Most of the similarity functions can handle one or many sce-
narios such as adding noise, increase/decrease of the sampling
rate, random shift, synchronized shift as concluded by Wang
et al. [37]. Designing a perfect similarity function which can
handle all the scenarios is an open research challenge.
(2) Most of the approaches proposed in the literature are generic
approaches for similarity computation in time series data
and applied those functions to GPS trajectories. We need to
consider specific properties of GPS trajectory data and design
a similarity function for GPS data.
(3) In most of the existing cryptosystems, we have to distribute
a common key for encryption to all the parties in order to
perform operations in the homomorphic encryption. Ideally,
the secured trajectory similarity functions should be able to
work on different keys for separate parties. There are few
works in literature proposed in the literature, e.g., Wang et al.
in [36]. Creating such an approach for evaluating trajectory
similarity would increase the security of the framework.
(4) Most of the methods proposed in the literature have a time
complexity of O(n2), except for ED which has a time complex-
ity of O(n)but cannot handle noise. We need to come up with
algorithms which are linear time algorithms which can also
handle noise. In the string matching domain, there are several
linear/sublinear time algorithms proposed by researchers. If
we modify them for use in the trajectory similarity domain,
then potentially they can provide linear/sublinear time com-
plexity. Creating the encrypted version of those methods to
achieve linear/sublinear time presents an even greater chal-
lenge.
(5) Very few non-cryptography based approaches for trajectory
similarity have been explored to date [30, 32]. Approaches
such as GeoSecure [24] consider only differences in succes-
sive points of a GPS trajectory and calculate approximate
distance, velocity, and acceleration using the haversine for-
mula. Since only the differences are shared with the LBS
provider, the location of the user is never revealed. If we
explore this idea further to create a similarity function to com-
pare relative distance, velocity, and acceleration of the two
trajectories, and then compare the heading of the trajectory
and the initial points of the trajectory securely, we could po-
tentially detect trajectory similarity. Furthermore, cloaking,
masking and anonymization related approaches needs further
improvements.
(6) Current approaches in the literature use partially homomor-
phic schemes or somewhat homomorphic schemes, which
only allow certain arithmetic operations. Hence, the methods
proposed by the researchers perform calculations for the oper-
ations not supported by encryption scheme before encryption
and then the data is sent for the comparison. For instance, the
square root operation is not supported by all the homomor-
phic schemes, so in order to evaluate a similarity function
involving square root operation, the schemes first calculate
the square root term in the plaintext domain and then send
that along with other terms for comparison with the other tra-
jectory. This involves overhead and increases bandwidth cost.
Hence, we need to work with efficient fully homomorphic
encryption schemes, which should ideally only accept plain-
text trajectory data and with minimal or no calculations in
plaintext domain we should be able to compute the similarity
between trajectories.
(7) Most of the encrypted domain approaches consider outdoor
trajectories consisting of GPS locations. Although there are
methods proposed to track location indoors securely, we did
not come across any methods to determine trajectory sim-
ilarity in indoor locations, in other words, non-GPS based
location trajectories.
(8) Current methods such as Paillier and ElGamal homomor-
phic encryption schemes are not secured against quantum
attacks. In the near future when the quantum computers will
be available, these popular homomorphic systems may be-
come obsolete. Hence, we also need to create new approaches
which will withstand quantum attacks.
5 CONCLUSION AND FUTURE WORK
In this paper, we reviewed the research work done on GPS trajectory
similarity computation in both the plaintext and encrypted domains.
In the plaintext domain, we conclude that the EDR based distance
similarity function is the best distance similarity measure compared
to the other similarity measures, in spite of having a higher com-
putational cost than ED because ED is not robust. However, in the
encrypted domain, the method provided by Liu et al. in [17] is the
most direct method for computing GPS trajectory similarity and
can support secure DTW, LCSS and EDR computation. Garbled
circuits is the most commonly used approach to compare data in
the encrypted domain. We also provided a list of the open research
challenges which will be useful for researchers.
REFERENCES
[1] Rakesh Agrawal, Christos Faloutsos, and Arun Swami. 1993. Efficient similarity
search in sequence databases. In Foundations of Data Organization and Algo-
rithms, David B. Lomet (Ed.). Springer Berlin Heidelberg, Berlin, Heidelberg.
[2] Appleinsider. 2018. Hundreds of iOS apps leaking data due to misconfig-
ured Firebase backends. (2018). https://appleinsider.com/articles/18/06/29/
hundreds-of-ios-apps-leaking-data-due-to-misconfigured-firebase-backends\
-report-says
[3] Dan Boneh and Brent Waters. 2007. Conjunctive, subset, and range queries on
encrypted data. In Theory of Cryptography Conference. Springer, 535–554.
[4] Lei Chen. 2005. Similarity search over time series and trajectory data. Ph.D.
Dissertation. Waterloo, ON, Canada.
[5] Lei Chen, M Tamer Özsu, and Vincent Oria. 2005. Robust and fast similarity
search for moving object trajectories. In The International Conference on Man-
agement of Data (SIGMOD). ACM, 491–502.
[6] Ivan Damgård, Martin Geisler, and Mikkel Krøigaard. 2007. Efficient and secure
comparison for on-line auctions. In Australasian Conference on Information
Security and Privacy. Springer, 416–430.
[7] Ning Guo, Mengyu Ma, Wei Xiong, Luo Chen, and Ning Jing. 2017. An efficient
query algorithm for trajectory similarity based on Fréchet distance threshold.
ISPRS International Journal of Geo-Information 6, 11 (2017), 326.
[8] Per Hallgren, Claudio Orlandi, and Andrei Sabelfeld. 2017. PrivatePool: privacy-
preserving ridesharing. In The 30th Computer Security Foundations Symposium
(CSF). IEEE, 276–291.
[9] Peizhao Hu, Sherman SM Chow, and Asma Aloufi. 2017. Geosocial query
with user-controlled privacy. In The 10th Conference on Security and Privacy in
Wireless and Mobile Networks. ACM, 163–172.
[10] Anas Ismail and Antoine Vigneron. 2015. A new trajectory similarity measure
for GPS data. In The 6th SIGSPATIAL International Workshop on GeoStreaming.
ACM, 19–22.
[11] Mohammed Waleed Kadous et al. 2002. Temporal classification: extending the
classification paradigm to multivariate time series. Ph.D. Dissertation. University
of New South Wales.
[12] Eamonn Keogh and Chotirat Ann Ratanamahatana. 2005. Exact indexing of
dynamic time warping. Knowledge and information systems 7, 3 (2005), 358–
386.
[13] Sang-Wook Kim, Sanghyun Park, and Wesley W Chu. 2001. An index-based
approach for similarity search supporting time warping in large sequence databases.
In The 17th International Conference on Data Engineering. 607–614.
[14] Xing-Xin Li, You-Wen Zhu, and Jian Wang. 2017. Efficient encrypted data com-
parison through a hybrid method. Journal of Information Science & Engineering
33, 4 (2017).
[15] Zi Lin, Denis Foo Kune, and Nicholas Hopper. 2012. Efficient private proximity
testing with gsm location sketches. In International Conference on Financial
Cryptography and Data Security. Springer, 73–88.
[16] Yehuda Lindell and Benny Pinkas. 2009. A proof of security of Yao’s protocol for
two-party computation. Journal of Cryptology 22, 2 (2009), 161–188.
[17] An Liu, Kai Zhengy, Lu Liz, Guanfeng Liu, Lei Zhao, and Xiaofang Zhou. 2015.
Efficient secure similarity computation on encrypted trajectory data. In IEEE 31st
International Conference on Data Engineering. 66–77.
[18] Nehal Magdy, Tamer Abdelkader, and Khaled El-Bahnasy. 2018. A comparative
study of similarity evaluation methods among trajectories of moving objects.
Egyptian Informatics Journal (2018).
[19] Nehal Magdy, Mahmoud A Sakr, Tamer Mostafa, and Khaled El-Bahnasy. 2015.
Review on trajectory similarity measures. In The Seventh International Conference
on Intelligent Computing and Information Systems (ICICIS). IEEE, 613–619.
[20] Yingchi Mao, Haishi Zhong, Xianjian Xiao, and Xiaofang Li. 2017. A segment-
based trajectory similarity measure in the urban transportation systems. MDPI
Sensors Journal 17, 3 (2017), 524.
[21] Marketsand Markets. 2018. Location-Based Services mar-
ket share. https://www.marketsandmarkets.com/Market-Reports/
location-based-service-market-96994431.html. (2018).
[22] Brendan Tran Morris and Mohan M Trivedi. 2011. Trajectory learning for activity
understanding: Unsupervised, multilevel, and long-term adaptive approach. IEEE
Transactions on Pattern Analysis and Machine Intelligence 33, 11 (2011), 2287–
2301.
[23] Arvind Narayanan, Narendran Thiagarajan, Mugdha Lakhani, Michael Hamburg,
Dan Boneh, et al. 2011. Location privacy via private proximity testing.. In NDSS,
Vol. 11.
[24] Vikram Patil, Shivam Parikh, Priyanka Singh, and Pradeep K Atrey. 2017. GeoSe-
cure: Towards secure outsourcing of GPS data over cloud. In IEEE Conference on
Communications and Network Security (CNS). IEEE, 495–501.
[25] Raluca Ada Popa, Catherine M. S. Redfield, Nickolai Zeldovich, and Hari Balakr-
ishnan. 2011. CryptDB: protecting confidentiality with encrypted query processing.
In The Twenty-Third Symposium on Operating Systems Principles (SOSP ’11).
85–100.
[26] Gokay Saldamli, Richard Chow, Hongxia Jin, and Bart Knijnenburg. 2013. Private
proximity testing with an untrusted server. In The sixth ACM conference on
Security and privacy in wireless and mobile networks. 113–118.
[27] Bharath Kumar Samanthula, Wei Jiang, and Elisa Bertino. 2014. Privacy-
preserving complex query evaluation over semantically secure encrypted data. In
European Symposium on Research in Computer Security. Springer, 400–418.
[28] Bharath K. K. Samanthula, Hu Chun, and Wei Jiang. 2013. An efficient and
probabilistic secure bit-decomposition. In The 8th Symposium on Information,
Computer and Communications Security (SIGSAC) (ASIA CCS ’13). 541–546.
[29] Adi Shamir. 1979. How to share a secret. Commun. ACM 22, 11 (Nov. 1979),
612–613.
[30] Ye Tian, Wendong Wang, Jie Wu, Qinli Kou, Zheng Song, and Edith C-H Ngai.
2017. Privacy-preserving social tie discovery based on cloaked human trajectories.
IEEE Transactions on Vehicular Technology 66, 2 (2017), 1619–1630.
[31] Kevin Toohey and Matt Duckham. 2015. Trajectory similarity measures. ACM
SIGSPATIAL Special 7, 1 (2015), 43–50.
[32] Christof Ferreira Torres and Rolando Trujillo-Rasua. 2016. The fréchet/manhattan
distance and the trajectory anonymisation problem. In IFIP Annual Conference on
Data and Applications Security and Privacy. Springer, 19–34.
[33] Thijs Veugen. 2011. Comparing encrypted data. Multimedia Signal Processing
Group, Delft University of Technology, The Netherlands, and TNO Information
and Communication Technology, Delft, The Netherlands, Tech. Rep (2011).
[34] M. Vlachos. [n. d.]. Multidimenstional time-Series datasets. ([n. d.]). http:
//alumni.cs.ucr.edu/~mvlachos/datasets.html
[35] Michail Vlachos, George Kollios, and Dimitrios Gunopulos. 2002. Discovering
similar multidimensional trajectories. In The 18th IEEE International Conference
on Data Engineering (ICDE). San Jose, CA, USA, 673–684.
[36] Boyang Wang, Ming Li, Sherman SM Chow, and Hui Li. 2014. A tale of two
clouds: Computing on data encrypted under multiple keys. In IEEE Conference
on Communications and Network Security (CNS). IEEE, 337–345.
[37] Haozhou Wang, Han Su, Kai Zheng, Shazia Sadiq, and Xiaofang Zhou. 2013.
An effectiveness study on trajectory similarity measures. In The Twenty-Fourth
Australasian Database Conference-Volume 137. 13–22.
[38] Chen Xu, Jingwei Chen, Wenyuan Wu, and Yong Feng. 2016. Homomorphically
encrypted arithmetic operations over the integer ring. In International Conference
on Information Security Practice and Experience. Springer, 167–181.
[39] Andrew Chi-Chih Yao. 1986. How to generate and exchange secrets. In 27th
Annual Symposium on Foundations of Computer Science (SFCS 1986). 162–167.
[40] Byoung-Kee Yi, HV Jagadish, and Christos Faloutsos. 1998. Efficient retrieval of
similar time sequences under time warping. In The 14th International Conference
on Data Engineering. IEEE, 201–208.
[41] Jing Yuan, Yu Zheng, Xing Xie, and Guangzhong Sun. 2011. Driving with
knowledge from the physical world. In The 17th ACM SIGKDD international
conference on Knowledge discovery and data mining. 316–324.
[42] Jing Yuan, Yu Zheng, Chengyang Zhang, Wenlei Xie, Xing Xie, Guangzhong
Sun, and Yan Huang. 2010. T-drive: driving directions based on taxi trajectories.
In The 18th SIGSPATIAL International conference on advances in geographic
information systems. ACM, 99–108.
[43] Yu Zheng, Hao Fu, Xing Xie, Wei-Ying Ma, and Quannan Li. 2011. Geolife
GPS trajectory dataset - User Guide. https://www.microsoft.com/en-us/research/
publication/geolife-gps-trajectory-dataset-user-guide/